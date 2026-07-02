import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  UseGuards,
  Put,
  Delete,
  Query,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { ProfileColabService } from './profile-colab.service';
import { CreateProfileColabDto } from './dto/create-profile-colab.dto';
import { UpdateProfileColabDto } from './dto/update-profile-colab.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UpdateLocationDto } from './dto/update-location.dto';
import { CurrentUser } from 'src/common/decorators/current-user.decorator';
import type { JwtPayload } from 'src/common/interfaces/jwt-payload.interface';

@ApiTags('profile-colab')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('profile-colab')
export class ProfileColabController {
  constructor(private profileColabService: ProfileColabService) {}

  @Post()
  @ApiOperation({ summary: 'Convertirse en colaborador' })
  create(@CurrentUser() user: JwtPayload, @Body() dto: CreateProfileColabDto) {
    return this.profileColabService.create(user.id, dto);
  }

  @Get('me')
  @ApiOperation({ summary: 'Ver mi perfil de colaborador' })
  getMyProfile(@CurrentUser() user: JwtPayload) {
    return this.profileColabService.getMyProfile(user.id);
  }

  @Patch('me')
  @ApiOperation({ summary: 'Actualizar mi perfil de colaborador' })
  update(@CurrentUser() user: JwtPayload, @Body() dto: UpdateProfileColabDto) {
    return this.profileColabService.update(user.id, dto);
  }

  @Put('me/location')
  @ApiOperation({ summary: 'Activar disponibilidad y actualizar ubicación' })
  updateLocation(
    @CurrentUser() user: JwtPayload,
    @Body() dto: UpdateLocationDto,
  ) {
    return this.profileColabService.updateLocation(
      user.id,
      dto.lat,
      dto.lng,
    );
  }

  @Delete('me/location')
  @ApiOperation({ summary: 'Desactivar disponibilidad' })
  deactivateLocation(@CurrentUser() user: JwtPayload) {
    return this.profileColabService.deactivateLocation(user.id);
  }

@Get('search')
@ApiOperation({ summary: 'Buscar colaboradores con filtros y paginación' })
@ApiQuery({ name: 'query', required: false, type: String })
@ApiQuery({ name: 'page', required: false, type: Number })
@ApiQuery({ name: 'limit', required: false, type: Number })
@ApiQuery({ name: 'name', required: false, type: String })
@ApiQuery({ name: 'occupation', required: false, type: String })
search(
  @Query('page') page: number = 1,
  @Query('limit') limit: number = 10,
  @Query('query') query?: string,
  @Query('name') name?: string,
  @Query('occupation') occupation?: string,
) {
  return this.profileColabService.search(+page, +limit, query, name, occupation);
}
}