import { Module } from '@nestjs/common';
import { CollabsGateway } from './colabs.gateway';
import { RedisService } from '../../common/services/redis.service';
import { RedisModule } from 'src/common/redis.module';

@Module({
  imports: [RedisModule],
  providers: [CollabsGateway, RedisService],
  exports: [CollabsGateway],
})
export class GatewayModule {}