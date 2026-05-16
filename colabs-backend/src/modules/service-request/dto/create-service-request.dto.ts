import {
  IsNumber,
  IsString,
  IsUUID,
  IsOptional,
  Min,
  Max,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateServiceRequestDto {
  @ApiProperty({ example: -12.046 })
  @IsNumber()
  @Min(-90)
  @Max(90)
  lat!: number;

  @ApiProperty({ example: -77.042 })
  @IsNumber()
  @Min(-180)
  @Max(180)
  lng!: number;

  @ApiProperty({ example: 'Av. Larco 420, Miraflores' })
  @IsString()
  direction!: string;

  @ApiProperty({ example: 'uuid-de-occupation' })
  @IsUUID()
  occupationId!: string;

  @ApiProperty({ example: 'Necesito instalar 3 tomacorrientes', required: false })
  @IsString()
  @IsOptional()
  description?: string;
}