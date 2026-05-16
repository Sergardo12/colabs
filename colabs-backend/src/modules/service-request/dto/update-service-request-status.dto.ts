import { IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { ServiceRequestStatus } from 'src/common/enums/service-request-status.enum';

export class UpdateServiceRequestStatusDto {
  @ApiProperty({ enum: ServiceRequestStatus })
  @IsEnum(ServiceRequestStatus)
  status!: ServiceRequestStatus;
}