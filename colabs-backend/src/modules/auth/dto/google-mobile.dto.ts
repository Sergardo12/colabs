import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class GoogleMobileDto {
  @ApiProperty({ example: 'eyJhbGciOiJSUzI1NiIsImtpZCI6...' })
  @IsString()
  idToken!: string;
}