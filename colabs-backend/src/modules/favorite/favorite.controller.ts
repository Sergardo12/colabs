import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  ParseUUIDPipe,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { FavoriteService } from './favorite.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from 'src/common/decorators/current-user.decorator';
import type { JwtPayload } from 'src/common/interfaces/jwt-payload.interface';

@ApiTags('favorites')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('favorites')
export class FavoriteController {
  constructor(private favoriteService: FavoriteService) {}

  @Get()
  @ApiOperation({ summary: 'Mis colaboradores favoritos' })
  findMyFavorites(@CurrentUser() user: JwtPayload) {
    return this.favoriteService.findMyFavorites(user.id);
  }

  @Post(':profileColabId')
  @ApiOperation({ summary: 'Agregar colaborador a favoritos' })
  add(
    @CurrentUser() user: JwtPayload,
    @Param('profileColabId', ParseUUIDPipe) profileColabId: string,
  ) {
    return this.favoriteService.add(user.id, profileColabId);
  }

  @Delete(':profileColabId')
  @ApiOperation({ summary: 'Quitar colaborador de favoritos' })
  remove(
    @CurrentUser() user: JwtPayload,
    @Param('profileColabId', ParseUUIDPipe) profileColabId: string,
  ) {
    return this.favoriteService.remove(user.id, profileColabId);
  }
}
