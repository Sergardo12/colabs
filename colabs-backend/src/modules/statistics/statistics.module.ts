import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommentRequest } from '../service-request/entities/comment-request.entity';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { User } from '../users/entities/user.entity';
import { ColabGuard } from './guards/colab.guard';
import { MonthlyGoal } from './entities/monthly-goal.entity';
import { StatisticsController } from './statistics.controller';
import { StatisticsService } from './statistics.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      MonthlyGoal,
      ProfileColab,
      User,
      ServiceRequest,
      CommentRequest,
    ]),
  ],
  controllers: [StatisticsController],
  providers: [StatisticsService, ColabGuard],
})
export class StatisticsModule {}
