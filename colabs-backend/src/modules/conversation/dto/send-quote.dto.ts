import { IsNumber, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SendQuoteDto {
  @ApiProperty({
    example: 150.0,
    description: 'Precio negociado de la cotización',
  })
  @IsNumber()
  @Min(1)
  amount!: number;
}
