import { IsString, IsUUID, IsOptional, IsBoolean } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateNotificationDto {
  @ApiProperty({ example: 'uuid-del-usuario' })
  @IsUUID()
  userId!: string;

  @ApiProperty({ example: 'proposal_received' })
  @IsString()
  type!: string;

  @ApiProperty({ example: 'Nueva propuesta' })
  @IsString()
  title!: string;

  @ApiProperty({ example: 'Carlos ofrece S/. 120 por tu solicitud' })
  @IsString()
  body!: string;

  @ApiProperty({ example: 'proposal', required: false })
  @IsString()
  @IsOptional()
  entityType?: string;

  @ApiProperty({ example: 'uuid-de-la-entidad', required: false })
  @IsUUID()
  @IsOptional()
  entityId?: string;

  @ApiProperty({ example: 'uuid-del-admin', required: false })
  @IsUUID()
  @IsOptional()
  adminSenderId?: string;
}