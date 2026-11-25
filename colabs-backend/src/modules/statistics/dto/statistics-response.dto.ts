import { ApiProperty } from '@nestjs/swagger';

class BarDto {
  @ApiProperty({ example: 1 })
  key!: number;

  @ApiProperty({ example: 3 })
  value!: number;
}

export class ServicesOfferedResponseDto {
  @ApiProperty({ example: 'days' })
  period!: string;

  @ApiProperty({ example: 2024 })
  accountCreatedYear!: number;

  @ApiProperty({ type: [BarDto] })
  bars!: BarDto[];
}

export class ServicesTotalResponseDto {
  @ApiProperty({ example: 'days' })
  period!: string;

  @ApiProperty({ example: 2 })
  total!: number;
}

export class ServicesRateResponseDto {
  @ApiProperty({ example: 12 })
  requested!: number;

  @ApiProperty({ example: 8 })
  offered!: number;
}

export class AverageRatingResponseDto {
  @ApiProperty({ example: 4.5, nullable: true })
  averageRating!: number | null;
}

export class MonthlyGoalResponseDto {
  @ApiProperty({ example: 20 })
  amount!: number;

  @ApiProperty({ example: 7 })
  offered!: number;

  @ApiProperty({ example: 11 })
  month!: number;

  @ApiProperty({ example: 2026 })
  year!: number;
}
