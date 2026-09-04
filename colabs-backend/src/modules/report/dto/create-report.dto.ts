import { IsUUID, IsString, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateReportDto {
  @ApiProperty({ example: 'uuid-del-usuario-reportado' })
  @IsUUID()
  reportedUserId!: string;

  @ApiProperty({ example: 'uuid-del-service-request', required: false })
  @IsUUID()
  @IsOptional()
  serviceRequestId?: string;

  @ApiProperty({ example: 'comportamiento_inapropiado' })
  @IsString()
  category!: string;

  @ApiProperty({ example: 'El colaborador no llegó a la cita acordada', required: false })
  @IsString()
  @IsOptional()
  description?: string;
}