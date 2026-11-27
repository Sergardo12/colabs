import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional } from 'class-validator';
import { StatisticsPeriod } from '../enums/statistics-period.enum';

export class StatisticsPeriodQueryDto {
  @ApiPropertyOptional({ enum: StatisticsPeriod, default: StatisticsPeriod.DAYS })
  @IsOptional()
  @IsEnum(StatisticsPeriod)
  period: StatisticsPeriod = StatisticsPeriod.DAYS;
}
