import { IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateSupportDto {
  @ApiProperty({ example: 'No puedo iniciar sesión con mi cuenta de Google' })
  @IsString()
  @MinLength(10)
  description!: string;
}