import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ServiceRequestController } from './service-request.controller';
import { ServiceRequestService } from './service-request.service';
import { ServiceRequest } from './entities/service-request.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { GatewayModule } from '../gateway/gateway.module';
import { RedisModule } from 'src/common/redis.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([ServiceRequest, ProfileColab]),
    GatewayModule,
    RedisModule,
  ],
  controllers: [ServiceRequestController],
  providers: [ServiceRequestService],
  exports: [ServiceRequestService],
})
export class ServiceRequestModule {}