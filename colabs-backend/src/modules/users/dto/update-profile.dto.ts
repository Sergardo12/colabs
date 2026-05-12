import { IsString, IsOptional, IsDateString, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateProfileDto {
  @ApiProperty({ example: 'Carlos', required: false })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiProperty({ example: 'Ríos', required: false })
  @IsString()
  @IsOptional()
  lastName?: string;

  @ApiProperty({ example: '999999999', required: false })
  @IsString()
  @IsOptional()
  @Matches(/^\+?[0-9]{7,15}$/, { message: 'Número de teléfono inválido' })
  phoneNumber?: string;

  @ApiProperty({ example: '1990-01-15', required: false })
  @IsDateString()
  @IsOptional()
  dateBirth?: string;

  @ApiProperty({ example: 'masculino', required: false })
  @IsString()
  @IsOptional()
  gender?: string;

  @ApiProperty({ example: 'https://cloudinary.com/photo.jpg', required: false })
  @IsString()
  @IsOptional()
  imageProfile?: string;
}