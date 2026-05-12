import { IsString, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateOccupationDto {
  @ApiProperty({ example: 'Electricidad' })
  @IsString()
  name!: string;

  @ApiProperty({ example: 'https://cloudinary.com/icon.png', required: false })
  @IsString()
  @IsOptional()
  image?: string;
}