import { IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum ServiceRequestStatus {
  CANCELLED = 'cancelled',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  DISPUTED = 'disputed',
  ACCEPTED = 'accepted',
}

export class UpdateServiceRequestStatusDto {
  @ApiProperty({ enum: ServiceRequestStatus })
  @IsEnum(ServiceRequestStatus)
  status!: ServiceRequestStatus;
}