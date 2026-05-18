import { IsString, IsOptional, IsNumber, IsEnum, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum MessageType {
  TEXT  = 'text',
  OFFER = 'offer',
}

export class SendMessageDto {
  @ApiProperty({ example: 'Hola, necesito instalar 3 tomacorrientes' })
  @IsString()
  content!: string;

  @ApiProperty({ enum: MessageType, default: MessageType.TEXT })
  @IsEnum(MessageType)
  @IsOptional()
  type?: MessageType = MessageType.TEXT;

  @ApiProperty({ example: 120.00, required: false })
  @IsNumber()
  @Min(1)
  @IsOptional()
  amount?: number;
}