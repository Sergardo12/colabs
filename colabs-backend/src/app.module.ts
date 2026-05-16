import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import databaseConfig from './config/database.config';
import redisConfig from './config/redis.config';
import jwtConfig from './config/jwt.config';
import { AuthModule } from './modules/auth/auth.module';
import { OccupationModule } from './modules/occupation/occupation.module';
import { UsersModule } from './modules/users/users.module';
import { ProfileColabModule } from './modules/profile-colab/profile-colab.module';
import { RedisService } from './common/services/redis.service';
import { GatewayModule } from './modules/gateway/gateway.module';
import { ServiceRequestModule } from './modules/service-request/service-request.module';
import { RedisModule } from './common/redis.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [databaseConfig, redisConfig, jwtConfig],
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('database.host'),
        port: configService.get<number>('database.port'),
        username: configService.get<string>('database.username'),
        password: configService.get<string>('database.password'),
        database: configService.get<string>('database.database'),
        entities: [__dirname + '/modules/**/entities/*.entity{.ts,.js}'],
        synchronize: process.env.NODE_ENV !== 'production',
        logging: process.env.NODE_ENV === 'development',
      }),
      inject: [ConfigService],
    }),
    RedisModule,
    AuthModule,
    OccupationModule,
    UsersModule,
    ProfileColabModule,
    GatewayModule,
    ServiceRequestModule,
  ],
})
export class AppModule {}