import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Report } from './entities/report.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { CreateReportDto } from './dto/create-report.dto';

@Injectable()
export class ReportService {
  constructor(
    @InjectRepository(Report)
    private reportRepository: Repository<Report>,

    @InjectRepository(ProfileColab)
    private profileColabRepository: Repository<ProfileColab>,
  ) {}

  async create(reporterId: string, dto: CreateReportDto) {
    let reportedUserId = dto.reportedUserId;

    if (!reportedUserId && dto.profileColabId) {
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

    const report = this.reportRepository.create({
      reporterId,
      reportedUserId,
      serviceRequestId: dto.serviceRequestId,
      category: dto.category,
      description: dto.description,
      status: 'pending',
    });

    return this.reportRepository.save(report);
  }

  async findMyReports(userId: string) {
    return this.reportRepository.find({
      where: { reporterId: userId },
      order: { date: 'DESC' },
    });
  }
}
