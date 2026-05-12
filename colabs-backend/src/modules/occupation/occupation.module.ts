import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OccupationController } from './occupation.controller';
import { OccupationService } from './occupation.service';
import { Occupation } from './entities/occupation.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Occupation])],
  controllers: [OccupationController],
  providers: [OccupationService],
  exports: [OccupationService],
})
export class OccupationModule {}