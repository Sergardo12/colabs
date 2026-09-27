import { Injectable, NotFoundException, ForbiddenException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Proposal } from './entities/proposal.entity';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { CommentRequest } from '../service-request/entities/comment-request.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { User } from '../users/entities/user.entity';
import { Conversation } from '../conversation/entities/conversation.entity';
import { Message } from '../message/entities/message.entity';
import { CreateProposalDto } from './dto/create-proposal.dto';
import { MessageType } from '../conversation/dto/send-message.dto';
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

    @InjectRepository(Conversation)
    private conversationRepository: Repository<Conversation>,

    @InjectRepository(Message)
    private messageRepository: Repository<Message>,

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

    // Verificar que no haya una propuesta ya aceptada para esta solicitud.
    // Si existe una pendiente previa, la cotización actual la reemplaza
    // (Flujo A: cotización preliminar en la card → cotización final en el chat).
    const existing = await this.proposalRepository.findOne({
      where: {
        profileColabId: profile.id,
        serviceRequestId: dto.serviceRequestId,
      },
      order: { createdAt: 'DESC' },
    });

    if (existing && existing.status === ProposalStatus.ACCEPTED) {
      throw new ConflictException('Ya enviaste una propuesta para esta solicitud');
    }

    if (existing && existing.status === ProposalStatus.PENDING) {
      existing.status = ProposalStatus.REJECTED;
      await this.proposalRepository.save(existing);
    }

    const proposal = this.proposalRepository.create({
      profileColabId: profile.id,
      serviceRequestId: dto.serviceRequestId,
      amount: dto.amount,
      status: ProposalStatus.PENDING,
    });

    const saved = await this.proposalRepository.save(proposal);

// Notifica al demandante de la nueva cotización (con distancia).
    await this.notifyProposalReceived(profile, serviceRequest, saved);

    // Disponibiliza el chat entre demandante y colaborador aunque la
    // solicitud siga pending (Flujo A: negociación de cotización final).
    await this.ensureConversation(
      serviceRequest.userId,
      profile.id,
      serviceRequest.id,
    );

    return saved;
  }

  /**
   * Cotización final desde el chat (Flujo A):
   * - SR pendiente: delega al flujo de la card (reemplaza la preliminar si hay).
   * - SR accepted (cotización preliminar ya aceptada): la nueva cotización
   *   convive con la aceptada hasta que el demandante decida; la aceptada solo
   *   se rechaza si esta nueva gana.
   */
  async createChatQuote(
    userId: string,
    serviceRequestId: string,
    amount: number,
  ) {
    const profile = await this.profileColabRepository.findOne({
      where: { userId },
      relations: ['user'],
    });

    if (!profile) {
      throw new ForbiddenException('Solo los colaboradores pueden enviar propuestas');
    }

    const serviceRequest = await this.serviceRequestRepository.findOne({
      where: { id: serviceRequestId },
      relations: ['occupation'],
    });

    if (!serviceRequest) {
      throw new NotFoundException('Solicitud no encontrada');
    }

    if (
      serviceRequest.status !== ServiceRequestStatus.PENDING &&
      serviceRequest.status !== ServiceRequestStatus.ACCEPTED
    ) {
      throw new ForbiddenException('Esta solicitud ya no está disponible');
    }

    if (serviceRequest.status === ServiceRequestStatus.PENDING) {
      return this.create(userId, { serviceRequestId, amount });
    }

    const existing = await this.proposalRepository.findOne({
      where: { profileColabId: profile.id, serviceRequestId },
      order: { createdAt: 'DESC' },
    });

    if (existing && existing.status === ProposalStatus.PENDING) {
      existing.status = ProposalStatus.REJECTED;
      await this.proposalRepository.save(existing);
    }

    const proposal = this.proposalRepository.create({
      profileColabId: profile.id,
      serviceRequestId,
      amount,
      status: ProposalStatus.PENDING,
    });

    const saved = await this.proposalRepository.save(proposal);

    await this.notifyProposalReceived(profile, serviceRequest, saved);

    // El canal ya existe (la solicitud está aceptada); no-op por seguridad.
    await this.ensureConversation(
      serviceRequest.userId,
      profile.id,
      serviceRequest.id,
    );

    return saved;
  }

  /**
   * Indica si el colaborador ya tiene una cotización sin respuesta
   * (pendiente de aceptar/rechazar) para la solicitud indicada.
   * Se usa para limitar a UNA cotización a la vez por colaborador.
   */
  async hasPendingProposal(profileColabId: string, serviceRequestId: string) {
    const count = await this.proposalRepository.count({
      where: {
        profileColabId,
        serviceRequestId,
        status: ProposalStatus.PENDING,
      },
    });
    return count > 0;
  }

  private async notifyProposalReceived(
    profile: ProfileColab,
    serviceRequest: ServiceRequest,
    proposal: Proposal,
  ) {
    // Distancia entre el colaborador (Redis) y la solicitud (PostGIS) — en km.
    // Si no se puede calcular (sin ubicación), se notifica igual con valor null.
    let distanceKm: number | null = null;
    try {
      const location =
        await this.redisService.getCollaboratorLocation(profile.userId);
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
          .where('sr.id = :id', { id: proposal.serviceRequestId })
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
      body: `Un colaborador ofrece S/. ${proposal.amount} por tu solicitud`,
      entityType: 'proposal',
      entityId: proposal.id,
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
      entityId: notification.entityId,
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
        amount: proposal.amount,
        distanceKm,
        colab: {
          id: profile.user.id,
          name: profile.user.name,
          lastName: profile.user.lastName,
          imageProfile: profile.user.imageProfile,
        },
      },
    });
  }

  private async ensureConversation(
    userId: string,
    profileColabId: string,
    serviceRequestId: string,
  ) {
    const existingConversation = await this.conversationRepository.findOne({
      where: { userId, profileColabId, serviceRequestId },
    });

    if (!existingConversation) {
      const conversation = this.conversationRepository.create({
        userId,
        profileColabId,
        serviceRequestId,
        status: 'open',
      });
      await this.conversationRepository.save(conversation);
    }
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
    const collabNotification = await this.notificationService.notify({
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

    // Crear conversación automáticamente entre solicitante y colaborador
    await this.ensureConversation(
      proposal.serviceRequest.userId,
      proposal.profileColabId,
      proposal.serviceRequestId,
    );

    // Emitir en tiempo real al colaborador (después de crear la conversación)
    this.gateway.emitNewNotification(proposal.profileColab.userId, {
      id:           collabNotification.id,
      userId:       proposal.profileColab.userId,
      type:         collabNotification.type,
      title:        collabNotification.title,
      body:         collabNotification.body,
      entityType:   collabNotification.entityType,
      entityId:     collabNotification.entityId,
      isRead:       false,
      creationDate: collabNotification.creationDate,
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
    const notification = await this.notificationService.notify({
      userId: proposal.profileColab.userId,
      type: 'proposal_rejected',
      title: 'Propuesta rechazada',
      body: `Tu propuesta de S/. ${proposal.amount} no fue aceptada`,
      entityType: 'service_request',
      entityId: proposal.serviceRequestId,
    });

    // Mensaje de sistema en el chat (si el canal ya existe) + emit en tiempo real
    const conversation = await this.conversationRepository.findOne({
      where: {
        userId:           proposal.serviceRequest.userId,
        profileColabId:   proposal.profileColabId,
        serviceRequestId: proposal.serviceRequestId,
      },
    });

    if (conversation) {
      const systemMessage = this.messageRepository.create({
        conversationId: conversation.id,
        senderId:       userId,
        content:        'Cotización rechazada. El colaborador puede enviar una nueva cotización si lo acuerdan.',
        type:           MessageType.TEXT,
        isRead:         false,
      });
      const savedMessage = await this.messageRepository.save(systemMessage);
      this.gateway.emitNewMessage(conversation.id, savedMessage);
    }

    this.gateway.emitNewNotification(proposal.profileColab.userId, {
      id:           notification.id,
      userId:       proposal.profileColab.userId,
      type:         notification.type,
      title:        notification.title,
      body:         notification.body,
      entityType:   notification.entityType,
      entityId:     notification.entityId,
      isRead:       false,
      creationDate: notification.creationDate,
    });

    return proposal;
  }

  async acceptQuote(conversationId: string, userId: string) {
    const conversation = await this.conversationRepository.findOne({
      where: { id: conversationId },
      relations: ['profileColab', 'profileColab.user', 'serviceRequest'],
    });

    if (!conversation) throw new NotFoundException('Conversación no encontrada');

    if (!conversation.serviceRequestId || conversation.postId) {
      throw new ForbiddenException(
        'Esta conversación no corresponde a una solicitud de servicio',
      );
    }

    if (conversation.userId !== userId) {
      throw new ForbiddenException('Solo el demandante puede aceptar la cotización');
    }

    // Solo se puede aceptar UNA cotización de chat por solicitud (precio
    // final fijo). El límite se basa en las conversaciones de la solicitud:
    // solo el accept de chat marca la conversación como 'accepted'. La
    // cotización inicial de la card no cuenta para este límite.
    const alreadyAcceptedChat = await this.conversationRepository.findOne({
      where: {
        serviceRequestId: conversation.serviceRequestId,
        postId:           IsNull(),
        status:           'accepted',
      },
    });

    if (alreadyAcceptedChat) {
      throw new ForbiddenException('Ya existe una cotización aceptada para esta solicitud');
    }

    const proposal = await this.proposalRepository.findOne({
      where: {
        serviceRequestId: conversation.serviceRequestId,
        profileColabId:   conversation.profileColabId,
        status:           ProposalStatus.PENDING,
      },
      relations: ['serviceRequest', 'profileColab', 'profileColab.user'],
    });

    if (!proposal) {
      throw new NotFoundException('No hay una cotización pendiente en esta conversación');
    }

    const serviceRequest = proposal.serviceRequest;

    if (
      serviceRequest.status !== ServiceRequestStatus.PENDING &&
      serviceRequest.status !== ServiceRequestStatus.ACCEPTED
    ) {
      throw new ForbiddenException('Esta solicitud ya no está disponible');
    }

    // Aceptar esta cotización
    proposal.status = ProposalStatus.ACCEPTED;
    await this.proposalRepository.save(proposal);

    // Rechazar las demás cotizaciones de la misma solicitud
    await this.proposalRepository
      .createQueryBuilder()
      .update(Proposal)
      .set({ status: ProposalStatus.REJECTED })
      .where('serviceRequestId = :serviceRequestId', {
        serviceRequestId: proposal.serviceRequestId,
      })
      .andWhere('id != :id', { id: proposal.id })
      .execute();

// La solicitud queda "aceptada" con el precio acordado; la transición a
    // "en proceso" la realiza únicamente el colaborador ganador desde su card
    // (PATCH /service-requests/:id/start).
    await this.serviceRequestRepository.update(
      { id: proposal.serviceRequestId },
      { status: ServiceRequestStatus.ACCEPTED, acceptanceDate: new Date() },
    );

    // La conversación queda cerrada para nuevas cotizaciones
    conversation.status = 'accepted';
    await this.conversationRepository.save(conversation);

    // Mensaje de sistema en la sala
    const systemMessage = this.messageRepository.create({
      conversationId,
      senderId: userId,
      content: `Cotización aceptada por S/. ${proposal.amount}. El servicio ha sido aceptado.`,
      type: MessageType.TEXT,
      isRead: false,
    });
    const savedMessage = await this.messageRepository.save(systemMessage);
    this.gateway.emitNewMessage(conversationId, savedMessage);

    return this.proposalRepository.findOne({
      where: { id: proposal.id },
      relations: ['serviceRequest', 'serviceRequest.occupation'],
    });
  }

  async rejectQuote(conversationId: string, userId: string) {
    const conversation = await this.conversationRepository.findOne({
      where: { id: conversationId },
      relations: ['profileColab', 'profileColab.user', 'serviceRequest'],
    });

    if (!conversation) throw new NotFoundException('Conversación no encontrada');

    if (!conversation.serviceRequestId || conversation.postId) {
      throw new ForbiddenException(
        'Esta conversación no corresponde a una solicitud de servicio',
      );
    }

    if (conversation.userId !== userId) {
      throw new ForbiddenException('Solo el demandante puede rechazar la cotización');
    }

    const proposal = await this.proposalRepository.findOne({
      where: {
        serviceRequestId: conversation.serviceRequestId,
        profileColabId:   conversation.profileColabId,
        status:           ProposalStatus.PENDING,
      },
      relations: ['serviceRequest', 'profileColab'],
    });

    if (!proposal) {
      throw new NotFoundException('No hay una cotización pendiente en esta conversación');
    }

    if (proposal.serviceRequest.status !== ServiceRequestStatus.PENDING &&
      proposal.serviceRequest.status !== ServiceRequestStatus.ACCEPTED) {
      throw new ForbiddenException('Esta solicitud ya no está disponible');
    }

    proposal.status = ProposalStatus.REJECTED;
    await this.proposalRepository.save(proposal);

    // Mensaje de sistema en la sala
    const systemMessage = this.messageRepository.create({
      conversationId,
      senderId: userId,
      content: 'Cotización rechazada. El colaborador puede enviar una nueva cotización si lo acuerdan.',
      type: MessageType.TEXT,
      isRead: false,
    });
    const savedMessage = await this.messageRepository.save(systemMessage);
    this.gateway.emitNewMessage(conversationId, savedMessage);

    // Notificar al colaborador
    const notification = await this.notificationService.notify({
      userId: proposal.profileColab.userId,
      type: 'proposal_rejected',
      title: 'Cotización rechazada',
      body: `Tu cotización de S/. ${proposal.amount} fue rechazada`,
      entityType: 'service_request',
      entityId: proposal.serviceRequestId,
    });

    this.gateway.emitNewNotification(proposal.profileColab.userId, {
      id:           notification.id,
      userId:       proposal.profileColab.userId,
      type:         notification.type,
      title:        notification.title,
      body:         notification.body,
      entityType:   notification.entityType,
      entityId:     notification.entityId,
      isRead:       false,
      creationDate: notification.creationDate,
    });

    return proposal;
  }

  async getQuoteStatus(conversationId: string, userId: string) {
    const conversation = await this.conversationRepository.findOne({
      where: { id: conversationId },
      relations: ['profileColab', 'serviceRequest'],
    });

    if (!conversation) throw new NotFoundException('Conversación no encontrada');

    const isParticipant =
      conversation.userId === userId ||
      conversation.profileColab.userId === userId;

    if (!isParticipant) {
      throw new ForbiddenException('No tienes acceso a esta conversación');
    }

    if (!conversation.serviceRequestId || conversation.postId) {
      return {
        status: 'none',
        amount: null,
        serviceRequestStatus: null,
        acceptedAmount: null,
      };
    }

    const proposal = await this.proposalRepository.findOne({
      where: {
        serviceRequestId: conversation.serviceRequestId,
        profileColabId:   conversation.profileColabId,
      },
      order: { createdAt: 'DESC' },
    });

    if (!proposal) {
      return {
        status: 'none',
        amount: null,
        serviceRequestStatus: conversation.serviceRequest?.status ?? null,
        acceptedAmount: null,
      };
    }

    const acceptedProposal = await this.proposalRepository.findOne({
      where: {
        serviceRequestId: conversation.serviceRequestId,
        profileColabId:   conversation.profileColabId,
        status:           ProposalStatus.ACCEPTED,
      },
      order: { createdAt: 'DESC' },
    });

    return {
      status: proposal.status,
      amount: Number(proposal.amount),
      serviceRequestStatus: conversation.serviceRequest?.status ?? null,
      acceptedAmount:
        acceptedProposal != null ? Number(acceptedProposal.amount) : null,
    };
  }
}