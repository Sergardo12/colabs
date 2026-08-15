import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Conversation } from './entities/conversation.entity';
import { Message } from '../message/entities/message.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { Occupation } from '../occupation/entities/occupation.entity';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendMessageDto, MessageType } from './dto/send-message.dto';
import { AcceptOfferDto } from './dto/accept-offer.dto';
import { ServiceRequestStatus } from '../../common/enums/service-request-status.enum';
import { CollabsGateway } from '../gateway/colabs.gateway';

@Injectable()
export class ConversationService {
  constructor(
    @InjectRepository(Conversation)
    private conversationRepository: Repository<Conversation>,

    @InjectRepository(Message)
    private messageRepository: Repository<Message>,

    @InjectRepository(ProfileColab)
    private profileColabRepository: Repository<ProfileColab>,

    @InjectRepository(ServiceRequest)
    private serviceRequestRepository: Repository<ServiceRequest>,

    @InjectRepository(Occupation)
    private occupationRepository: Repository<Occupation>,

    private collabsGateway: CollabsGateway,
  ) {}

  async create(userId: string, dto: CreateConversationDto) {
    // Verificar que el colaborador existe
    const profileColab = await this.profileColabRepository.findOne({
      where: { id: dto.profileColabId },
      relations: ['occupations'],
    });

    if (!profileColab) {
      throw new NotFoundException('Colaborador no encontrado');
    }

    // Verificar que no existe ya una conversación activa entre ellos
    const existing = await this.conversationRepository.findOne({
      where: {
        userId,
        profileColabId: dto.profileColabId,
        status: 'open',
      },
    });

    if (existing) {
      throw new ConflictException('Ya tienes una conversación activa con este colaborador');
    }

    const conversation = this.conversationRepository.create({
      userId,
      profileColabId: dto.profileColabId,
      postId: dto.postId,
      status: 'open',
    });

    return this.conversationRepository.save(conversation);
  }

  async findMyConversations(userId: string) {
    const conversations = await this.conversationRepository
      .createQueryBuilder('conversation')
      .leftJoinAndSelect('conversation.profileColab', 'profileColab')
      .leftJoinAndSelect('profileColab.user', 'colabUser')
      .leftJoinAndSelect('profileColab.occupations', 'occupations')
      .leftJoinAndSelect('conversation.post', 'post')
      .leftJoinAndSelect('conversation.user', 'user')
      .leftJoin('conversation.messages', 'lastMessage')
      .addSelect('MAX(lastMessage.created_at)', 'last_message_at')
      .where('conversation.user_id = :userId', { userId })
      .orWhere('profileColab.user_id = :userId', { userId })
      .groupBy('conversation.id')
      .addGroupBy('profileColab.id')
      .addGroupBy('colabUser.id')
      .addGroupBy('occupations.id')
      .addGroupBy('post.id')
      .addGroupBy('user.id')
      .orderBy('last_message_at', 'DESC', 'NULLS LAST')
      .addOrderBy('conversation.created_at', 'DESC')
      .getRawAndEntities();

    const { entities, raw } = conversations;

    // Agregar unreadCount y lastMessageAt a cada conversación
    const result = await Promise.all(
      entities.map(async (conversation, index) => {
        const unreadCount = await this.messageRepository.count({
          where: {
            conversationId: conversation.id,
            isRead: false,
            senderId: conversation.userId === userId
              ? conversation.profileColab.userId
              : conversation.userId,
          },
        });

        return {
          ...conversation,
          lastMessageAt: raw[index]?.last_message_at ?? conversation.createdAt,
          unreadCount,
        };
      }),
    );

    return result;
  }

  async findOne(id: string, userId: string) {
    const conversation = await this.conversationRepository.findOne({
      where: { id },
      relations: [
        'profileColab',
        'profileColab.user',
        'profileColab.occupations',
      ],
    });

    if (!conversation) throw new NotFoundException('Conversación no encontrada');

    // Verificar que el usuario es parte de la conversación
    const isParticipant =
      conversation.userId === userId ||
      conversation.profileColab.userId === userId;

    if (!isParticipant) {
      throw new ForbiddenException('No tienes acceso a esta conversación');
    }

    return conversation;
  }

  async sendMessage(conversationId: string, userId: string, dto: SendMessageDto) {
    const conversation = await this.findOne(conversationId, userId);

    if (conversation.status === 'closed' || conversation.status === 'expired') {
      throw new ForbiddenException('Esta conversación está cerrada');
    }

    // Si es una oferta — solo el colaborador puede enviarla
    if (dto.type === MessageType.OFFER) {
      if (conversation.profileColab.userId !== userId) {
        throw new ForbiddenException('Solo el colaborador puede enviar ofertas');
      }

      if (!dto.amount) {
        throw new ForbiddenException('La oferta debe incluir un monto');
      }

      // Actualiza el status de la conversación
      conversation.status = 'offer_sent';
      await this.conversationRepository.save(conversation);
    }

    const message = this.messageRepository.create({
      conversationId,
      senderId: userId,
      content: dto.content,
      type: dto.type ?? MessageType.TEXT,
      amount: dto.amount,
      isRead: false,
    });

    const saved = await this.messageRepository.save(message);
    this.collabsGateway.emitNewMessage(conversationId, saved);
    return saved;
  }

  async findMessages(conversationId: string, userId: string) {
    await this.findOne(conversationId, userId);

    // Marca mensajes como leídos
    await this.messageRepository
      .createQueryBuilder()
      .update(Message)
      .set({ isRead: true })
      .where('conversationId = :conversationId', { conversationId })
      .andWhere('senderId != :userId', { userId })
      .execute();

    return this.messageRepository.find({
      where: { conversationId },
      relations: ['sender'],
      order: { createdAt: 'ASC' },
    });
  }

  async acceptOffer(conversationId: string, userId: string, dto: AcceptOfferDto) {
    const conversation = await this.conversationRepository.findOne({
      where: { id: conversationId },
      relations: ['profileColab', 'profileColab.occupations'],
    });

    if (!conversation) throw new NotFoundException('Conversación no encontrada');

    // Solo el demandante puede aceptar
    if (conversation.userId !== userId) {
      throw new ForbiddenException('Solo el demandante puede aceptar la oferta');
    }

    if (conversation.status !== 'offer_sent') {
      throw new ForbiddenException('No hay una oferta pendiente en esta conversación');
    }

    // Obtener el monto de la última oferta
    const lastOffer = await this.messageRepository.findOne({
      where: {
        conversationId,
        type: MessageType.OFFER,
      },
      order: { createdAt: 'DESC' },
    });

    if (!lastOffer) throw new NotFoundException('No se encontró la oferta');

    // Obtener la primera ocupación del colaborador
    const occupationId = conversation.profileColab.occupations[0]?.id;

    if (!occupationId) {
      throw new ForbiddenException('El colaborador no tiene ocupaciones registradas');
    }

    // Crear el service_request automáticamente
    const serviceRequest = this.serviceRequestRepository.create({
      userId,
      occupationId,
      direction: dto.direction,
      description: `Servicio coordinado via chat — S/. ${lastOffer.amount}`,
      status: ServiceRequestStatus.ACCEPTED,
      acceptanceDate: new Date(),
    });

    const saved = await this.serviceRequestRepository.save(serviceRequest);

    // Vincular la conversación con el service_request
    conversation.status = 'accepted';
    conversation.serviceRequestId = saved.id;
    await this.conversationRepository.save(conversation);

    // Mensaje del sistema
    const systemMessage = this.messageRepository.create({
      conversationId,
      senderId: userId,
      content: `Oferta aceptada. Se creó la solicitud de servicio por S/. ${lastOffer.amount}`,
      type: MessageType.TEXT,
      isRead: false,
    });
    await this.messageRepository.save(systemMessage);

    return {
      conversation,
      serviceRequest: saved,
    };
  }
}