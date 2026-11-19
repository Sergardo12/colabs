import { IsOptional, IsString, MaxLength } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class GetCancelledWithColabQueryDto {
  @ApiPropertyOptional({
    description:
      'Filtra por nombre de ocupación o descripción del servicio (case-insensitive)',
    example: 'electricista',
  })
  @IsOptional()
  @IsString()
  @MaxLength(120)
  search?: string;
}
