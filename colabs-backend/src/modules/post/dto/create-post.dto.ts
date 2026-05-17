import {
  IsString,
  IsOptional,
  IsArray,
  IsNumber,
  IsUrl,
  Min,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreatePostDto {
  @ApiProperty({ example: 'Prueba este pie de limón con base crujiente' })
  @IsString()
  description!: string;

  @ApiProperty({
    example: ['https://res.cloudinary.com/colabs/image/upload/v1/posts/abc.jpg'],
    required: false,
  })
  @IsArray()
  @IsUrl({}, { each: true })
  @IsOptional()
  media?: string[];

  @ApiProperty({ example: 75.00, required: false })
  @IsNumber()
  @Min(0)
  @IsOptional()
  price?: number;
}