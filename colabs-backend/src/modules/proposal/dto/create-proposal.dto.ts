import { IsUUID, IsNumber, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProposalDto {
  @ApiProperty({ example: 'uuid-del-service-request' })
  @IsUUID()
  serviceRequestId!: string;

  @ApiProperty({ example: 150.0 })
  @IsNumber()
  @Min(1)
  amount!: number;
}
