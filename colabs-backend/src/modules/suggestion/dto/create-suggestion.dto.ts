import { IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateSuggestionDto {
  @ApiProperty({ example: 'Sería útil poder filtrar colaboradores por precio' })
  @IsString()
  @MinLength(10)
  description!: string;
}