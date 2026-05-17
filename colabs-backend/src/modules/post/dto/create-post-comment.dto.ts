import { IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreatePostCommentDto {
  @ApiProperty({ example: 'Excelente trabajo, muy profesional' })
  @IsString()
  @MinLength(1)
  comment!: string;
}