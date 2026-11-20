import { IsUUID, IsString, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateReportDto {
  @ApiPropertyOptional({
    example: 'uuid-del-usuario-reportado',
    description:
      'ID del usuario reportado. Si no se envía, se resuelve desde profileColabId.',
  })
  @IsUUID()
  @IsOptional()
  reportedUserId?: string;

  @ApiPropertyOptional({
    example: 'uuid-del-profile-colab',
    description: 'ID del colaborador ganador (profile_colab).',
  })
  @IsUUID()
  @IsOptional()
  profileColabId?: string;

  @ApiPropertyOptional({ example: 'uuid-del-service-request' })
  @IsUUID()
  @IsOptional()
  serviceRequestId?: string;

  @ApiProperty({ example: 'comportamiento_inapropiado' })
  @IsString()
  category!: string;

  @ApiPropertyOptional({
    example: 'El colaborador no llegó a la cita acordada',
  })
  @IsString()
  @IsOptional()
  description?: string;
}
