import { IsEmail, IsString, MinLength, IsOptional, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'carlos@gmail.com' })
  @IsEmail()
  email!: string;

  @ApiProperty({ example: 'Carlos' })
  @IsString()
  name!: string;

  @ApiProperty({ example: 'Ríos' })
  @IsString()
  lastName!: string;

  @ApiProperty({ example: 'password123', minLength: 6 })
  @IsString()
  @MinLength(6)
  password!: string;

  @ApiProperty({ example: '999999999', required: false })
  @IsString()
  @IsOptional()
  @Length(9, 9, { message: 'El número de teléfono debe tener 9 dígitos' })
  phoneNumber?: string;
}