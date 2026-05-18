import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { CreateCommentRequestDto } from './dto/create-comment-request.dto';
import { ServiceRequestStatus } from '../../common/enums/service-request-status.enum';
import { CommentRequest } from '../service-request/entities/comment-request.entity';

@Injectable()
export class CommentRequestService {
  constructor(
    @InjectRepository(CommentRequest)
    private commentRequestRepository: Repository<CommentRequest>,

    @InjectRepository(ServiceRequest)
    private serviceRequestRepository: Repository<ServiceRequest>,
  ) {}

  async create(userId: string, dto: CreateCommentRequestDto) {
    // Verificar que la solicitud existe
    const serviceRequest = await this.serviceRequestRepository.findOne({
      where: { id: dto.serviceRequestId },
    });

    if (!serviceRequest) {
      throw new NotFoundException('Solicitud no encontrada');
    }

    // Solo el dueño puede calificar
    if (serviceRequest.userId !== userId) {
      throw new ForbiddenException('Solo puedes calificar tus propias solicitudes');
    }

    // Solo se califica si el servicio está completado
    if (serviceRequest.status !== ServiceRequestStatus.COMPLETED) {
      throw new ForbiddenException('Solo puedes calificar servicios completados');
    }

    // Verificar que no haya calificado ya
    const existing = await this.commentRequestRepository.findOne({
      where: { serviceRequestId: dto.serviceRequestId },
    });

    if (existing) {
      throw new ConflictException('Ya calificaste este servicio');
    }

    const commentRequest = this.commentRequestRepository.create({
      userId,
      serviceRequestId: dto.serviceRequestId,
      rating: dto.rating,
      comment: dto.comment,
      status: 'active',
    });

    return this.commentRequestRepository.save(commentRequest);
  }

  async findMyReviews(userId: string) {
    return this.commentRequestRepository.find({
      where: { userId },
      relations: ['serviceRequest', 'serviceRequest.occupation'],
      order: { creationDate: 'DESC' },
    });
  }

  async findByProfileColab(profileColabId: string) {
    // Busca todas las calificaciones de los servicios del colaborador
    const comments = await this.commentRequestRepository
      .createQueryBuilder('cr')
      .innerJoinAndSelect('cr.serviceRequest', 'sr')
      .innerJoinAndSelect('sr.occupation', 'occupation')
      .innerJoinAndSelect('cr.user', 'user')
      .where('sr.occupationId IN (SELECT occupation_id FROM profile_colab_occupations WHERE profile_colab_id = :profileColabId)', 
        { profileColabId })
      .orderBy('cr.creationDate', 'DESC')
      .getMany();

    // Calcular rating promedio
    const averageRating = comments.length > 0
      ? comments.reduce((sum, c) => sum + (c.rating ?? 0), 0) / comments.length
      : 0;

    return {
      averageRating: Math.round(averageRating * 10) / 10,
      totalReviews: comments.length,
      comments,
    };
  }
}