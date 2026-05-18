import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProposalController } from './proposal.controller';
import { ProposalService } from './proposal.service';
import { Proposal } from './entities/proposal.entity';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { NotificationModule } from '../notification/notification.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Proposal, ServiceRequest, ProfileColab]),
    NotificationModule,
  ],
  controllers: [ProposalController],
  providers: [ProposalService],
  exports: [ProposalService],
})
export class ProposalModule {}