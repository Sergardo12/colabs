import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Proposal } from './entities/proposal.entity';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { CreateProposalDto } from './dto/create-proposal.dto';
import { ProposalStatus } from 'src/common/enums/proposal-status.enum';
import { ServiceRequestStatus } from 'src/common/enums/service-request-status.enum';
import { NotificationService } from '../notification/notification.service';

@Injectable()
export class ProposalService {
  constructor(
    @InjectRepository(Proposal)
    private proposalRepository: Repository<Proposal>,

    @InjectRepository(ServiceRequest)
    private serviceRequestRepository: Repository<ServiceRequest>,

    @InjectRepository(ProfileColab)
    private profileColabRepository: Repository<ProfileColab>,

    private notificationService: NotificationService,
  ) {}

  async create(userId: string, dto: CreateProposalDto) {
    // Verificar que el usuario es colaborador
    const profile = await this.profileColabRepository.findOne({
      where: { userId },
    });

    if (!profile) {
      throw new ForbiddenException('Solo los colaboradores pueden enviar propuestas');
    }

    // Verificar que la solicitud existe y está pending
    const serviceRequest = await this.serviceRequestRepository.findOne({
      where: { id: dto.serviceRequestId },
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

    // Notifica al demandante
    await this.notificationService.notify({
      userId: serviceRequest.userId,
      type: 'proposal_received',
      title: 'Nueva propuesta',
      body: `Un colaborador ofrece S/. ${dto.amount} por tu solicitud`,
      entityType: 'proposal',
      entityId: saved.id,
    })

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

    return this.proposalRepository.find({
      where: { serviceRequestId },
      relations: ['profileColab', 'profileColab.occupations'],
      order: { amount: 'ASC' },
    });
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

    return this.proposalRepository.findOne({
      where: { id: proposal.id },
      relations: ['serviceRequest', 'serviceRequest.occupation'],
    });
  }

  async reject(id: string, userId: string) {
    const proposal = await this.proposalRepository.findOne({
      where: { id },
      relations: ['serviceRequest'],
    });

    if (!proposal) throw new NotFoundException('Propuesta no encontrada');

    if (proposal.serviceRequest.userId !== userId) {
      throw new ForbiddenException('No puedes rechazar esta propuesta');
    }

    proposal.status = ProposalStatus.REJECTED;
    return this.proposalRepository.save(proposal);
  }
}