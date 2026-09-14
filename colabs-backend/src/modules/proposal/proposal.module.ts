import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProposalController } from './proposal.controller';
import { ProposalService } from './proposal.service';
import { Proposal } from './entities/proposal.entity';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { User } from '../users/entities/user.entity';
import { Conversation } from '../conversation/entities/conversation.entity';
import { NotificationModule } from '../notification/notification.module';
import { GatewayModule } from '../gateway/gateway.module';
import { RedisModule } from '../../common/redis.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Proposal, ServiceRequest, ProfileColab, User, Conversation]),
    NotificationModule,
    GatewayModule,
    RedisModule,
  ],
  controllers: [ProposalController],
  providers: [ProposalService],
  exports: [ProposalService],
})
export class ProposalModule {}