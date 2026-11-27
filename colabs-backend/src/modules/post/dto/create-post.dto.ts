import {
  IsString,
  IsOptional,
  IsArray,
  IsNumber,
  IsUrl,
  Min,
  MaxLength,
  ArrayMinSize,
  ArrayMaxSize,
  ArrayUnique,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export const MAX_POST_MEDIA = 5;

export class CreatePostDto {
  @ApiProperty({ example: 'Prueba este pie de limón con base crujiente' })
  @IsString()
  @MaxLength(2000)
  description!: string;

  @ApiProperty({
    description: 'URLs públicas obtenidas de POST /storage/presign (kind=post)',
    example: [
      'https://<tu-base-publica-b2>/post/<userId>/<uuid>.jpg',
    ],
    minItems: 1,
    maxItems: MAX_POST_MEDIA,
  })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(MAX_POST_MEDIA)
  @ArrayUnique()
  @IsString({ each: true })
  @MaxLength(500, { each: true })
  @IsUrl({}, { each: true })
  media!: string[];

  @ApiProperty({ example: 75.0, required: false })
  @IsNumber()
  @Min(0)
  @IsOptional()
  price?: number;
}