import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { ServiceRequest } from './entities/service-request.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { User } from '../users/entities/user.entity';
import { Occupation } from '../occupation/entities/occupation.entity';
import { Conversation } from '../conversation/entities/conversation.entity';
import { Message } from '../message/entities/message.entity';
import { MessageType } from '../conversation/dto/send-message.dto';
import { RedisService } from '../../common/services/redis.service';
import { CollabsGateway } from '../gateway/colabs.gateway';
import { CreateServiceRequestDto } from './dto/create-service-request.dto';
import { UpdateServiceRequestStatusDto } from './dto/update-service-request-status.dto';
import { ServiceRequestStatus } from 'src/common/enums/service-request-status.enum';
import { ProposalStatus } from 'src/common/enums/proposal-status.enum';
import { NotificationService } from '../notification/notification.service';

@Injectable()
export class ServiceRequestService {
  constructor(
    @InjectRepository(ServiceRequest)
    private serviceRequestRepository: Repository<ServiceRequest>,

    @InjectRepository(ProfileColab)
    private profileColabRepository: Repository<ProfileColab>,

    @InjectRepository(User)
    private userRepository: Repository<User>,

    @InjectRepository(Occupation)
    private occupationRepository: Repository<Occupation>,

    @InjectRepository(Conversation)
    private conversationRepository: Repository<Conversation>,

    @InjectRepository(Message)
    private messageRepository: Repository<Message>,

    private notificationService: NotificationService,
    private redisService: RedisService,
    private collabsGateway: CollabsGateway,
  ) {}

  async create(userId: string, dto: CreateServiceRequestDto) {
    // Crear la solicitud con PostGIS
    const serviceRequest = this.serviceRequestRepository.create({
      userId,
      occupationId:   dto.occupationId,
      direction:      dto.direction,
      description:    dto.description,
      profileColabId: dto.profileColabId,
      status:         ServiceRequestStatus.PENDING,
    });

    const saved = await this.serviceRequestRepository.save(serviceRequest) as ServiceRequest;

    // Actualiza la ubicación con PostGIS por separado
    await this.serviceRequestRepository
    .createQueryBuilder()
    .update(ServiceRequest)
    .set({
        location: () => `ST_SetSRID(ST_MakePoint(${dto.lng}, ${dto.lat}), 4326)`,
    })
    .where('id = :id', { id: saved.id })
    .execute();

    // Flujo C — solicitud directa a un colaborador específico
    if (dto.profileColabId) {
      // Notificar solo a ese colaborador via WebSocket
      this.collabsGateway.emitNewServiceRequest(
        [dto.profileColabId],
        {
          id:          saved.id,
          occupationId: saved.occupationId,
          direction:   saved.direction,
          description: saved.description,
          lat:         dto.lat,
          lng:         dto.lng,
        },
      );

      // Notificación persistente solo a ese colaborador
      const occupation = await this.occupationRepository.findOne({
        where: { id: dto.occupationId },
      });
      const occupationName = occupation?.name ?? 'Servicio';

      // Obtener el userId del profileColab
      const profileColab = await this.profileColabRepository.findOne({
        where: { id: dto.profileColabId },
      });

      if (profileColab) {
        await this.notificationService.notify({
          userId:     profileColab.userId,
          type:       'service_request_new',
          title:      `Solicitud directa: ${occupationName}`,
          body:       saved.description ?? saved.direction ?? '',
          entityType: 'service_request',
          entityId:   saved.id,
        });
      }

      return this.serviceRequestRepository.findOne({
        where:     { id: saved.id },
        relations: ['occupation'],
      });
    }

    // Flujo A — solicitud a colaboradores cercanos (código existente sin cambios)
    const nearbyCollaborators = await this.redisService
      .findNearbyCollaborators(dto.occupationId);

    // Filtrar por radio de 5km usando Haversine
    const inRange = nearbyCollaborators.filter(colab => {
      const distance = this.haversineDistance(
        dto.lat, dto.lng,
        colab.lat, colab.lng,
      );
      return distance <= 5;
    });

    // Notificar a cada colaborador en rango via WebSocket
    if (inRange.length > 0) {
      const collaboratorIds = inRange.map(c => c.userId);
      this.collabsGateway.emitNewServiceRequest(collaboratorIds, {
        id: saved.id,
        occupationId: saved.occupationId,
        direction: saved.direction,
        description: saved.description,
        lat: dto.lat,
        lng: dto.lng,
      });

      // Marcar colaboradores como busy en Redis
      for (const colab of inRange) {
        await this.redisService.setCollaboratorStatus(colab.userId, 'busy');
      }
    }

    // Notificación persistente a TODOS los colaboradores de la ocupación (aunque offline).
    // Se excluye a sí mismo si el solicitante es colaborador de la misma ocupación.
    const occupation = await this.occupationRepository.findOne({
      where: { id: dto.occupationId },
    });

    const targets = await this.profileColabRepository
      .createQueryBuilder('pc')
      .innerJoin('pc.occupations', 'occ')
      .where('occ.id = :occupationId', { occupationId: dto.occupationId })
      .andWhere('pc.userId != :userId', { userId })
      .getMany();

    if (targets.length > 0) {
      const occupationName = occupation?.name ?? 'Servicio';
      const notifications = targets.map(target =>
        this.notificationService.notify({
          userId: target.userId,
          type: 'service_request_new',
          title: `Nueva solicitud: ${occupationName}`,
          body: dto.description ?? dto.direction ?? '',
          entityType: 'service_request',
          entityId: saved.id,
        }),
      );
      // Procesar en lotes para evitar saturar la conexión
      for (let i = 0; i < notifications.length; i += 50) {
        await Promise.all(notifications.slice(i, i + 50));
      }
    }

    return this.serviceRequestRepository.findOne({
        where: { id: saved.id },
      relations: ['occupation'],
    });
  }

  async findMyRequests(userId: string) {
    const requests = await this.serviceRequestRepository.find({
      where: { userId },
      relations: [
        'occupation',
        'proposals',
        'proposals.profileColab',
        'proposals.profileColab.user',
      ],
      order: { creationDate: 'DESC' },
    });

    // Añade el número de propuestas/cotizaciones pendientes recibidas por solicitud
    return requests.map(request => ({
      ...request,
      proposalsCount:
        request.proposals?.filter(p => p.status === ProposalStatus.PENDING)
          .length ?? 0,
    }));
  }

  async findOne(id: string, userId: string) {
    const request = await this.serviceRequestRepository.findOne({
      where: { id },
      relations: ['occupation', 'proposals', 'proposals.profileColab'],
    });

    if (!request) throw new NotFoundException('Solicitud no encontrada');

    return request;
  }

  async findNearby(userId: string) {
    // Obtener ubicación del colaborador desde Redis
    const location = await this.redisService.getCollaboratorLocation(userId);

    if (!location) {
      throw new ForbiddenException(
        'Debes activar tu disponibilidad antes de ver solicitudes cercanas',
      );
    }

    // Buscar perfil del colaborador para saber sus ocupaciones
    const profile = await this.profileColabRepository.findOne({
      where: { userId },
      relations: ['occupations'],
    });

    if (!profile) {
      throw new ForbiddenException('No tienes perfil de colaborador');
    }

    const occupationIds = profile.occupations.map(o => o.id);

    // Buscar solicitudes pending en PostgreSQL de la ocupación del colaborador:
    // - Dentro de un radio de 5km (PostGIS ST_DWithin sobre la columna geography)
    // - Excluye auto-solicitudes del propio colaborador (igual que en notificaciones)
    const requests = await this.serviceRequestRepository
      .createQueryBuilder('sr')
      .where('sr.status = :status', { status: ServiceRequestStatus.PENDING })
      .andWhere('sr.occupationId IN (:...occupationIds)', { occupationIds })
      .andWhere('sr.userId != :userId', { userId })
      .andWhere(
        `ST_DWithin(
          sr.location,
          ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography,
          5000
        )`,
        { lat: location.lat, lng: location.lng },
      )
      .andWhere(
        `NOT EXISTS (
          SELECT 1
          FROM proposals p
          WHERE p.service_request_id = sr.id
            AND p.profile_colab_id = :profileColabId
        )`,
        { profileColabId: profile.id },
      )
      .addSelect(
        `ST_Distance(
          sr.location,
          ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography
        )`,
        'distance',
      )
      .leftJoinAndSelect('sr.occupation', 'occupation')
      .leftJoinAndSelect('sr.user', 'user')
      .orderBy('sr.creationDate', 'DESC')
      .getRawAndEntities();

    // Solicitudes accepted/en proceso/completadas en las que este
    // colaborador fue elegido (radio/ocupación libre). Solo apps con
    // propuesta aceptada: tanto Flow A (aceptada vía card o vía chat) —
    // el Flow B crea SR sin propuesta, así que queda correctamente
    // excluido. Las completadas quedan visibles como historial del
    // ganador y se hunden al final del tablero (ver return).
    const acceptedRaw = await this.serviceRequestRepository
      .createQueryBuilder('sr')
      .andWhere('sr.status IN (:...statuses)', {
        statuses: [
          ServiceRequestStatus.ACCEPTED,
          ServiceRequestStatus.IN_PROGRESS,
          ServiceRequestStatus.COMPLETED,
        ],
      })
      .andWhere(
        `EXISTS (
          SELECT 1
          FROM proposals p
          WHERE p.service_request_id = sr.id
            AND p.profile_colab_id = :profileColabId
            AND p.status = 'accepted'
        )`,
        { profileColabId: profile.id },
      )
      .addSelect(
        `ST_Distance(
          sr.location,
          ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography
        )`,
        'distance',
      )
      .leftJoinAndSelect('sr.occupation', 'occupation')
      .leftJoinAndSelect('sr.user', 'user')
      .leftJoinAndSelect(
        'sr.proposals',
        'proposals',
        'proposals.status = :acceptedStatus',
        { acceptedStatus: ProposalStatus.ACCEPTED },
      )
      .leftJoinAndSelect('proposals.profileColab', 'proposalColab')
      .leftJoinAndSelect('proposalColab.user', 'proposalUser')
      .orderBy('sr.acceptanceDate', 'DESC')
      .setParameters({ lat: location.lat, lng: location.lng })
      .getRawAndEntities();

    const pending  = requests.entities.map((r, i) => ({ ...r, distanceKm: Number(requests.raw[i].distance) / 1000 }));
    const accepted = acceptedRaw.entities.map((r, i) => ({ ...r, distanceKm: Number(acceptedRaw.raw[i].distance) / 1000 }));

    // Trabajo activo primero, pendientes después y completadas al fondo
    // del tablero (historial del colaborador, sin ocupar el foco).
    const active = accepted.filter(
      (r) => r.status !== ServiceRequestStatus.COMPLETED,
    );
    const completed = accepted.filter(
      (r) => r.status === ServiceRequestStatus.COMPLETED,
    );

    return [...active, ...pending, ...completed];
  }

  async updateStatus(
    id: string,
    userId: string,
    dto: UpdateServiceRequestStatusDto,
  ) {
    const request = await this.serviceRequestRepository.findOne({
      where: { id },
    });

    if (!request) throw new NotFoundException('Solicitud no encontrada');

    // Solo el dueño de la solicitud puede cambiar el estado
    if (request.userId !== userId) {
      throw new ForbiddenException('No tienes permiso para modificar esta solicitud');
    }

    request.status = dto.status;

    if (dto.status === ServiceRequestStatus.COMPLETED) {
      request.completionDate = new Date();
    }

    if (dto.status === ServiceRequestStatus.ACCEPTED) {
      request.acceptanceDate = new Date();
    }

    return this.serviceRequestRepository.save(request);
  }

  // Inicia el trabajo (accepted → in_progress) — exclusivo del colaborador
  // cuya propuesta fue aceptada por el demandante.
  async startWork(id: string, userId: string) {
    const profile = await this.profileColabRepository.findOne({
      where: { userId },
    });

    if (!profile) {
      throw new ForbiddenException('Solo los colaboradores pueden iniciar el trabajo');
    }

    const request = await this.serviceRequestRepository.findOne({
      where: { id },
    });

    if (!request) throw new NotFoundException('Solicitud no encontrada');

    if (request.status !== ServiceRequestStatus.ACCEPTED) {
      throw new ForbiddenException('Esta solicitud no está en estado aceptado');
    }

    // Solo el colaborador cuya propuesta fue aceptada puede iniciar el trabajo
    const winner = await this.serviceRequestRepository
      .createQueryBuilder('sr')
      .where('sr.id = :id', { id })
      .andWhere(
        `EXISTS (
          SELECT 1
          FROM proposals p
          WHERE p.service_request_id = sr.id
            AND p.profile_colab_id = :profileColabId
            AND p.status = :acceptedStatus
        )`,
        {
          profileColabId: profile.id,
          acceptedStatus: ProposalStatus.ACCEPTED,
        },
      )
      .getOne();

    if (!winner) {
      throw new ForbiddenException(
        'Solo el colaborador cuya propuesta fue aceptada puede iniciar el trabajo',
      );
    }

    request.status = ServiceRequestStatus.IN_PROGRESS;
    return this.serviceRequestRepository.save(request);
  }

  // Completa el trabajo (in_progress → completed) — exclusivo del mismo
  // colaborador ganador que inició el trabajo (mismo guard que startWork;
  // el estado in_progress garantiza que la secuencia del Flujo A ya pasó
  // por pending → accepted).
  async completeWork(id: string, userId: string) {
    const profile = await this.profileColabRepository.findOne({
      where: { userId },
    });

    if (!profile) {
      throw new ForbiddenException(
        'Solo los colaboradores pueden finalizar el servicio',
      );
    }

    const request = await this.serviceRequestRepository.findOne({
      where: { id },
    });

    if (!request) throw new NotFoundException('Solicitud no encontrada');

    if (request.status !== ServiceRequestStatus.IN_PROGRESS) {
      throw new ForbiddenException('Esta solicitud no está en estado en proceso');
    }

    // Solo el colaborador cuya propuesta fue aceptada puede finalizar
    const winner = await this.serviceRequestRepository
      .createQueryBuilder('sr')
      .where('sr.id = :id', { id })
      .andWhere(
        `EXISTS (
          SELECT 1
          FROM proposals p
          WHERE p.service_request_id = sr.id
            AND p.profile_colab_id = :profileColabId
            AND p.status = :acceptedStatus
        )`,
        {
          profileColabId: profile.id,
          acceptedStatus: ProposalStatus.ACCEPTED,
        },
      )
      .getOne();

    if (!winner) {
      throw new ForbiddenException(
        'Solo el colaborador cuya propuesta fue aceptada puede finalizar el servicio',
      );
    }

    request.status = ServiceRequestStatus.COMPLETED;
    request.completionDate = new Date();
    const saved = await this.serviceRequestRepository.save(request);

    // Mensaje de sistema + cierre del canal de la solicitud (Flow A):
    // la conversación se listada igual (sin filtro de estado en el chat),
    // solo se bloquean nuevos envíos con un 403 'conversación cerrada'.
    const conversation = await this.conversationRepository.findOne({
      where: { serviceRequestId: saved.id, postId: IsNull() },
    });

    if (conversation) {
      const systemMessage = this.messageRepository.create({
        conversationId: conversation.id,
        senderId: userId,
        content: 'Servicio completado. El trabajo ha finalizado.',
        type: MessageType.TEXT,
        isRead: false,
      });
      const savedMessage = await this.messageRepository.save(systemMessage);

      conversation.status = 'closed';
      await this.conversationRepository.save(conversation);

      this.collabsGateway.emitNewMessage(conversation.id, savedMessage);
    }

    // Notifica al demandante (patrón igual a proposal.service)
    const colabUser = await this.userRepository.findOne({
      where: { id: userId },
    });
    const colabName = colabUser
      ? `${colabUser.name} ${colabUser.lastName}`.trim()
      : 'Tu colaborador';

    const notification = await this.notificationService.notify({
      userId: request.userId,
      type: 'service_completed',
      title: 'Servicio completado',
      body: `${colabName} completó tu solicitud. Ya puedes calificar el servicio.`,
      entityType: 'service_request',
      entityId: saved.id,
    });

    this.collabsGateway.emitNewNotification(request.userId, {
      id: notification.id,
      userId: notification.userId,
      type: notification.type,
      title: notification.title,
      body: notification.body,
      entityType: notification.entityType,
      entityId: notification.entityId,
      isRead: notification.isRead,
      creationDate: notification.creationDate,
    });

    return saved;
  }

  // Fórmula Haversine — distancia entre dos puntos en km
  private haversineDistance(
    lat1: number, lng1: number,
    lat2: number, lng2: number,
  ): number {
    const R = 6371;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(lat1 * Math.PI / 180) *
      Math.cos(lat2 * Math.PI / 180) *
      Math.sin(dLng / 2) ** 2;
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  }
}