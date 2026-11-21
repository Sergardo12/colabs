import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { StorageService } from './storage.service';
import { PresignUploadDto } from './dto/presign-upload.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import type { JwtPayload } from '../../common/interfaces/jwt-payload.interface';

@ApiTags('storage')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('storage')
export class StorageController {
  constructor(private storageService: StorageService) {}

  @Post('presign')
  @ApiOperation({ summary: 'URL prefirmada para subir una imagen' })
  presign(@CurrentUser() user: JwtPayload, @Body() dto: PresignUploadDto) {
    return this.storageService.presignUpload(user.id, dto);
  }
}