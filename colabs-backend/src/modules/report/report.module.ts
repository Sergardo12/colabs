import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReportController } from './report.controller';
import { ReportService } from './report.service';
import { Report } from './entities/report.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Report, ProfileColab])],
  controllers: [ReportController],
  providers: [ReportService],
  exports: [ReportService],
})
export class ReportModule {}
