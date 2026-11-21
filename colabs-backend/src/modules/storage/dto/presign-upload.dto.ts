import { IsEnum, IsIn, IsInt, Max, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum UploadKind {
  POST = 'post',
  AVATAR = 'avatar',
  DNI = 'dni',
}

export const ALLOWED_MIME = ['image/jpeg', 'image/png', 'image/webp'];
export const MAX_SIZE_BYTES = 5 * 1024 * 1024; // 5 MB

export class PresignUploadDto {
  @ApiProperty({ enum: UploadKind })
  @IsEnum(UploadKind)
  kind!: UploadKind;

  @ApiProperty({ example: 'image/webp' })
  @IsIn(ALLOWED_MIME)
  contentType!: string;

  @ApiProperty({ example: 350000, description: 'Tamaño en bytes' })
  @IsInt()
  @Min(1)
  @Max(MAX_SIZE_BYTES)
  size!: number;
}