import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { QueryFailedError, Repository } from 'typeorm';
import { Report } from './entities/report.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { CreateReportDto } from './dto/create-report.dto';
import { ServiceRequestStatus } from 'src/common/enums/service-request-status.enum';
import { ProposalStatus } from 'src/common/enums/proposal-status.enum';

const ALREADY_REPORTED_MESSAGE = 'Este servicio ya fue reportado';

@Injectable()
export class ReportService {
  constructor(
    @InjectRepository(Report)
    private reportRepository: Repository<Report>,

    @InjectRepository(ProfileColab)
    private profileColabRepository: Repository<ProfileColab>,

    @InjectRepository(ServiceRequest)
    private serviceRequestRepository: Repository<ServiceRequest>,
  ) {}

  async create(reporterId: string, dto: CreateReportDto) {
    let reportedUserId = dto.reportedUserId;

    if (dto.serviceRequestId) {
      const serviceRequest = await this.serviceRequestRepository.findOne({
        where: { id: dto.serviceRequestId },
        relations: ['profileColab', 'proposals', 'proposals.profileColab'],
      });

      if (!serviceRequest) {
        throw new NotFoundException('Solicitud de servicio no encontrada');
      }

      if (serviceRequest.userId !== reporterId) {
        throw new ForbiddenException(
          'No puedes reportar un servicio que no te pertenece',
        );
      }

      if (
        serviceRequest.status !== (ServiceRequestStatus.CANCELLED as string)
      ) {
        throw new BadRequestException(
          'Solo se pueden reportar servicios cancelados',
        );
      }

      const acceptedProposal = serviceRequest.proposals?.find(
        (proposal) => proposal.status === (ProposalStatus.ACCEPTED as string),
      );
      const winnerProfileColab =
        serviceRequest.profileColab ?? acceptedProposal?.profileColab;
      const winnerProfileColabId =
        serviceRequest.profileColabId ?? acceptedProposal?.profileColabId;

      if (!winnerProfileColabId || !winnerProfileColab?.userId) {
        throw new BadRequestException(
          'El servicio no tiene colaborador ganador',
        );
      }

      reportedUserId = winnerProfileColab.userId;
    } else if (!reportedUserId && dto.profileColabId) {
      const profileColab = await this.profileColabRepository.findOne({
        where: { id: dto.profileColabId },
      });

      if (!profileColab) {
        throw new NotFoundException('Colaborador no encontrado');
      }

      reportedUserId = profileColab.userId;
    }

    if (!reportedUserId) {
      throw new BadRequestException(
        'Debes indicar reportedUserId o profileColabId',
      );
    }

    if (reportedUserId === reporterId) {
      throw new BadRequestException('No puedes reportarte a ti mismo');
    }

    if (dto.serviceRequestId) {
      const existingReport = await this.reportRepository.findOne({
        where: { serviceRequestId: dto.serviceRequestId },
      });

      if (existingReport) {
        throw new ConflictException(ALREADY_REPORTED_MESSAGE);
      }
    }

    const report = this.reportRepository.create({
      reporterId,
      reportedUserId,
      serviceRequestId: dto.serviceRequestId,
      category: dto.category,
      description: dto.description,
      status: 'pending',
    });

    try {
      return await this.reportRepository.save(report);
    } catch (error) {
      if (error instanceof QueryFailedError) {
        const driverError = error.driverError as
          | { code?: string; constraint?: string }
          | undefined;

        if (
          driverError?.code === '23505' &&
          driverError?.constraint === 'uq_reports_service_request_id'
        ) {
          throw new ConflictException(ALREADY_REPORTED_MESSAGE);
        }
      }
      throw error;
    }
  }

  async findMyReports(userId: string) {
    return this.reportRepository.find({
      where: { reporterId: userId },
      order: { date: 'DESC' },
    });
  }
}
