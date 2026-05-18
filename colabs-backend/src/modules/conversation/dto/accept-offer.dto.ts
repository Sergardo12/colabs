import { IsOptional, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AcceptOfferDto {
  @ApiProperty({ 
    example: 'Av. Larco 420, Miraflores',
    required: false,
    description: 'Dirección opcional — solo si el servicio es a domicilio'
  })
  @IsString()
  @IsOptional()
  direction?: string;
}