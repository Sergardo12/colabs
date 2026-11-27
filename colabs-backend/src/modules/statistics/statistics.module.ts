import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommentRequestModule } from '../comment-request/comment-request.module';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { User } from '../users/entities/user.entity';
import { ColabGuard } from './guards/colab.guard';
import { MonthlyGoal } from './entities/monthly-goal.entity';
import { StatisticsController } from './statistics.controller';
import { StatisticsService } from './statistics.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([MonthlyGoal, ProfileColab, User, ServiceRequest]),
    CommentRequestModule,
  ],
  controllers: [StatisticsController],
  providers: [StatisticsService, ColabGuard],
})
export class StatisticsModule {}
