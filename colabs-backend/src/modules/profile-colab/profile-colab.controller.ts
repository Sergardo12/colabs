import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  UseGuards,
  Request,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { ProfileColabService } from './profile-colab.service';
import { CreateProfileColabDto } from './dto/create-profile-colab.dto';
import { UpdateProfileColabDto } from './dto/update-profile-colab.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('profile-colab')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('profile-colab')
export class ProfileColabController {
  constructor(private profileColabService: ProfileColabService) {}

  @Post()
  @ApiOperation({ summary: 'Convertirse en colaborador' })
  create(@Request() req: any, @Body() dto: CreateProfileColabDto) {
    return this.profileColabService.create(req.user.id, dto);
  }

  @Get('me')
  @ApiOperation({ summary: 'Ver mi perfil de colaborador' })
  getMyProfile(@Request() req: any) {
    return this.profileColabService.getMyProfile(req.user.id);
  }

  @Patch('me')
  @ApiOperation({ summary: 'Actualizar mi perfil de colaborador' })
  update(@Request() req: any, @Body() dto: UpdateProfileColabDto) {
    return this.profileColabService.update(req.user.id, dto);
  }
}