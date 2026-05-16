import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProfileColabController } from './profile-colab.controller';
import { ProfileColabService } from './profile-colab.service';
import { ProfileColab } from './entities/profile-colab.entity';
import { Occupation } from '../occupation/entities/occupation.entity';
import { User } from '../users/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProfileColab, Occupation, User]),
  ],
  controllers: [ProfileColabController],
  providers: [ProfileColabService],
  exports: [ProfileColabService],
})
export class ProfileColabModule {}