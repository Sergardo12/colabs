import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConversationController } from './conversation.controller';
import { ConversationService } from './conversation.service';
import { Conversation } from './entities/conversation.entity';
import { Message } from '../message/entities/message.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { Occupation } from '../occupation/entities/occupation.entity';
import { GatewayModule } from '../gateway/gateway.module';
import { ProposalModule } from '../proposal/proposal.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Conversation,
      Message,
      ProfileColab,
      ServiceRequest,
      Occupation,
    ]),
    GatewayModule,
    ProposalModule,
  ],
  controllers: [ConversationController],
  providers: [ConversationService],
  exports: [ConversationService],
})
export class ConversationModule {}
