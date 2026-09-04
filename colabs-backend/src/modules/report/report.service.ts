import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Report } from './entities/report.entity';
import { CreateReportDto } from './dto/create-report.dto';

@Injectable()
export class ReportService {
  constructor(
    @InjectRepository(Report)
    private reportRepository: Repository<Report>,
  ) {}

  async create(reporterId: string, dto: CreateReportDto) {
    const report = this.reportRepository.create({
      reporterId,
      reportedUserId: dto.reportedUserId,
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