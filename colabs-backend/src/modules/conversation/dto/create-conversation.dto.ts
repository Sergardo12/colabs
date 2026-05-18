import { IsUUID, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateConversationDto {
  @ApiProperty({ example: 'uuid-del-profile-colab' })
  @IsUUID()
  profileColabId!: string;

  @ApiProperty({ example: 'uuid-del-post', required: false })
  @IsUUID()
  @IsOptional()
  postId?: string;
}