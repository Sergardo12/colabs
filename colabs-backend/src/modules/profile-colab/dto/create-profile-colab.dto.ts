import {
  IsString,
  IsOptional,
  IsArray,
  IsUUID,
  MinLength,
  ArrayMinSize,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProfileColabDto {
  @ApiProperty({ example: 'Experto en instalaciones eléctricas residenciales' })
  @IsString()
  @MinLength(10)
  description!: string;

  @ApiProperty({ example: '5 años' })
  @IsString()
  experience!: string;

  @ApiProperty({ example: '12345678' })
  @IsString()
  dni!: string;

  @ApiProperty({
    example: ['uuid-occupation-1', 'uuid-occupation-2'],
    description: 'IDs de las ocupaciones seleccionadas',
  })
  @IsArray()
  @IsUUID('4', { each: true })
  @ArrayMinSize(1)
  occupationIds!: string[];

  @ApiProperty({
    example: 'https://cloudinary.com/dni-image.jpg',
    required: false,
  })
  @IsString()
  @IsOptional()
  dniImage?: string;

  @ApiProperty({
    example: 'Certificado SENATI 2023',
    required: false,
  })
  @IsString()
  @IsOptional()
  certifications?: string;
}