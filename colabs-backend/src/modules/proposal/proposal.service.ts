import { Injectable, NotFoundException, ForbiddenException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Proposal } from './entities/proposal.entity';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { CommentRequest } from '../service-request/entities/comment-request.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { User } from '../users/entities/user.entity';
import { CreateProposalDto } from './dto/create-proposal.dto';
import { ProposalStatus } from 'src/common/enums/proposal-status.enum';
import { ServiceRequestStatus } from 'src/common/enums/service-request-status.enum';
import { NotificationService } from '../notification/notification.service';
import { RedisService } from 'src/common/services/redis.service';
import { CollabsGateway } from '../gateway/colabs.gateway';

@Injectable()
export class ProposalService {
  constructor(
    @InjectRepository(Proposal)
    private proposalRepository: Repository<Proposal>,

    @InjectRepository(ServiceRequest)
    private serviceRequestRepository: Repository<ServiceRequest>,

    @InjectRepository(ProfileColab)
    private profileColabRepository: Repository<ProfileColab>,

    @InjectRepository(User)
    private userRepository: Repository<User>,

    private notificationService: NotificationService,
    private redisService: RedisService,
    private gateway: CollabsGateway,
  ) {}

  async create(userId: string, dto: CreateProposalDto) {
    // Verificar que el usuario es colaborador
    const profile = await this.profileColabRepository.findOne({
      where: { userId },
      relations: ['user'],
    });

    if (!profile) {
      throw new ForbiddenException('Solo los colaboradores pueden enviar propuestas');
    }

    // Verificar que la solicitud existe y está pending
    const serviceRequest = await this.serviceRequestRepository.findOne({
      where: { id: dto.serviceRequestId },
      relations: ['occupation'],
    });

    if (!serviceRequest) {
      throw new NotFoundException('Solicitud no encontrada');
    }

    if (serviceRequest.status !== ServiceRequestStatus.PENDING) {
      throw new ForbiddenException('Esta solicitud ya no está disponible');
    }

    // Verificar que no haya enviado ya una propuesta
    const existing = await this.proposalRepository.findOne({
      where: {
        profileColabId: profile.id,
        serviceRequestId: dto.serviceRequestId,
      },
    });

    if (existing) {
      throw new ConflictException('Ya enviaste una propuesta para esta solicitud');
    }

    const proposal = this.proposalRepository.create({
      profileColabId: profile.id,
      serviceRequestId: dto.serviceRequestId,
      amount: dto.amount,
      status: ProposalStatus.PENDING,
    });

    const saved = await this.proposalRepository.save(proposal);

    // Distancia entre el colaborador (Redis) y la solicitud (PostGIS) — en km.
    // Si no se puede calcular (sin ubicación), se notifica igual con valor null.
    let distanceKm: number | null = null;
    try {
      const location = await this.redisService.getCollaboratorLocation(userId);
      if (location && serviceRequest.location) {
        const distanceResult = await this.serviceRequestRepository
          .createQueryBuilder('sr')
          .select(
            `ST_Distance(
              sr.location,
              ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography
            )`,
            'distance',
          )
          .where('sr.id = :id', { id: saved.serviceRequestId })
          .setParameters({ lat: location.lat, lng: location.lng })
          .getRawOne();
        if (distanceResult && distanceResult.distance != null) {
          distanceKm = Number(distanceResult.distance) / 1000;
        }
      }
    } catch (_) {
      distanceKm = null;
    }

    // Notifica al demandante que recibió una propuesta
    const notification = await this.notificationService.notify({
      userId: serviceRequest.userId,
      type: 'proposal_received',
      title: 'Nueva propuesta',
      body: `Un colaborador ofrece S/. ${dto.amount} por tu solicitud`,
      entityType: 'proposal',
      entityId: saved.id,
      data: { distanceKm },
    });

    // Emite la notificación en tiempo real al solicitante (si está conectado)
    this.gateway.emitNewNotification(serviceRequest.userId, {
      id: notification.id,
      userId: serviceRequest.userId,
      type: notification.type,
      title: notification.title,
      body: notification.body,
      entityType: notification.entityType,
      entityId: saved.id,
      isRead: false,
      creationDate: notification.creationDate,
      serviceRequest: {
        id: serviceRequest.id,
        description: serviceRequest.description,
        direction: serviceRequest.direction,
        occupationName: serviceRequest.occupation?.name ?? null,
      },
      requester: {
        id: profile.user.id,
        name: profile.user.name,
        lastName: profile.user.lastName,
        imageProfile: profile.user.imageProfile,
      },
      proposal: {
        amount: dto.amount,
        distanceKm,
        colab: {
          id: profile.user.id,
          name: profile.user.name,
          lastName: profile.user.lastName,
          imageProfile: profile.user.imageProfile,
        },
      },
    });

    return saved;
  }

  

  async findMyProposals(userId: string) {
    const profile = await this.profileColabRepository.findOne({
      where: { userId },
    });

    if (!profile) {
      throw new ForbiddenException('No tienes perfil de colaborador');
    }

    return this.proposalRepository.find({
      where: { profileColabId: profile.id },
      relations: ['serviceRequest', 'serviceRequest.occupation'],
      order: { createdAt: 'DESC' },
    });
  }

  async findByServiceRequest(serviceRequestId: string, userId: string) {
    // Verificar que es el dueño de la solicitud
    const serviceRequest = await this.serviceRequestRepository.findOne({
      where: { id: serviceRequestId, userId },
    });

    if (!serviceRequest) {
      throw new ForbiddenException('No tienes acceso a estas propuestas');
    }

    const { entities, raw } = await this.proposalRepository
      .createQueryBuilder('proposal')
      .leftJoinAndSelect('proposal.serviceRequest', 'serviceRequest')
      .leftJoinAndSelect('proposal.profileColab', 'profileColab')
      .leftJoinAndSelect('profileColab.user', 'user')
      .where('proposal.serviceRequestId = :serviceRequestId', {
        serviceRequestId,
      })
      .andWhere('proposal.status = :proposalStatus', {
        proposalStatus: ProposalStatus.PENDING,
      })
      .orderBy('proposal.amount', 'ASC')
      .addSelect(
        (sub) =>
          sub
            .select('AVG(cr.rating)', 'avg_rating')
            .from(CommentRequest, 'cr')
            .innerJoin(
              Proposal,
              'p',
              'p.service_request_id = cr.service_request_id',
            )
            .where('p.profile_colab_id = profileColab.id')
            .andWhere('cr.status = :status', { status: 'active' }),
        'avg_rating',
      )
      .getRawAndEntities();

    entities.forEach((proposal, i) => {
      (proposal as any).profileColab.averageRating =
        Math.round(Number(raw[i]?.avg_rating ?? 0) * 10) / 10;
    });

    return entities;
  }

  async accept(id: string, userId: string) {
    const proposal = await this.proposalRepository.findOne({
      where: { id },
      relations: ['serviceRequest', 'profileColab'],
    });

    if (!proposal) throw new NotFoundException('Propuesta no encontrada');

    // Verificar que es el dueño de la solicitud
    if (proposal.serviceRequest.userId !== userId) {
      throw new ForbiddenException('No puedes aceptar esta propuesta');
    }

    if (proposal.serviceRequest.status !== ServiceRequestStatus.PENDING) {
      throw new ForbiddenException('Esta solicitud ya no está disponible');
    }

    // Aceptar esta propuesta
    proposal.status = ProposalStatus.ACCEPTED;
    await this.proposalRepository.save(proposal);

    // Rechazar las demás propuestas de la misma solicitud
    await this.proposalRepository
      .createQueryBuilder()
      .update(Proposal)
      .set({ status: ProposalStatus.REJECTED })
      .where('serviceRequestId = :serviceRequestId', {
        serviceRequestId: proposal.serviceRequestId,
      })
      .andWhere('id != :id', { id: proposal.id })
      .execute();

    // Actualizar el estado de la solicitud a accepted
    await this.serviceRequestRepository.update(
      { id: proposal.serviceRequestId },
      { status: ServiceRequestStatus.ACCEPTED, acceptanceDate: new Date() },
    );

    // Notificar al colaborador 
    await this.notificationService.notify({
      userId: proposal.profileColab.userId,
      type: 'proposal_accepted',
      title: 'Propuesta aceptada',
      body: `Tu propuesta de S/. ${proposal.amount} fue aceptada`,
      entityType: 'service_request',
      entityId: proposal.serviceRequestId,
    });

    // Notificar al solicitante (Caso 2) — "Aceptado por {nombre del colaborador}"
    const collabUser = await this.userRepository.findOne({
      where: { id: proposal.profileColab.userId },
    });

    const collabName = collabUser
      ? `${collabUser.name} ${collabUser.lastName}`
      : 'un colaborador';

    await this.notificationService.notify({
      userId: proposal.serviceRequest.userId,
      type: 'service_request_accepted',
      title: `Aceptado por ${collabName}`,
      body: proposal.serviceRequest.description ?? '',
      entityType: 'service_request',
      entityId: proposal.serviceRequestId,
    });

    return this.proposalRepository.findOne({
      where: { id: proposal.id },
      relations: ['serviceRequest', 'serviceRequest.occupation'],
    });
  }

  async reject(id: string, userId: string) {
    const proposal = await this.proposalRepository.findOne({
      where: { id },
      relations: ['serviceRequest', 'profileColab'],
    });

    if (!proposal) throw new NotFoundException('Propuesta no encontrada');

    if (proposal.serviceRequest.userId !== userId) {
      throw new ForbiddenException('No puedes rechazar esta propuesta');
    }

    proposal.status = ProposalStatus.REJECTED;
    await this.proposalRepository.save(proposal);

    // Notificar al colaborador
    await this.notificationService.notify({
      userId: proposal.profileColab.userId,
      type: 'proposal_rejected',
      title: 'Propuesta rechazada',
      body: `Tu propuesta de S/. ${proposal.amount} no fue aceptada`,
      entityType: 'service_request',
      entityId: proposal.serviceRequestId,
    });

    return proposal;
  }
}