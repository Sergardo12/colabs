import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CommentRequestController } from './comment-request.controller';
import { CommentRequestService } from './comment-request.service';
import { CommentRequest } from '../service-request/entities/comment-request.entity';
import { ServiceRequest } from '../service-request/entities/service-request.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([CommentRequest, ServiceRequest]),
  ],
  controllers: [CommentRequestController],
  providers: [CommentRequestService],
  exports: [CommentRequestService],
})
export class CommentRequestModule {}