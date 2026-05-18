import { IsUUID, IsString, IsInt, Min, Max, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateCommentRequestDto {
  @ApiProperty({ example: 'uuid-del-service-request' })
  @IsUUID()
  serviceRequestId!: string;

  @ApiProperty({ example: 5, minimum: 1, maximum: 5 })
  @IsInt()
  @Min(1)
  @Max(5)
  rating!: number;

  @ApiProperty({ example: 'Excelente trabajo, muy puntual y profesional', required: false })
  @IsString()
  @IsOptional()
  comment?: string;
}