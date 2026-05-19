import {
  Controller,
  Get,
  Patch,
  Delete,
  Post,
  Body,
  Param,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from 'src/common/decorators/current-user.decorator';
import type { JwtPayload } from 'src/common/interfaces/jwt-payload.interface';

@ApiTags('users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('profile')
  @ApiOperation({ summary: 'Ver mi perfil completo' })
  getMyProfile(@CurrentUser() user: JwtPayload) {
    return this.usersService.getMyProfile(user.id);
  }

  @Patch('profile')
  @ApiOperation({ summary: 'Actualizar mi perfil' })
  updateProfile(
    @CurrentUser() user: JwtPayload,
    @Body() updateProfileDto: UpdateProfileDto,
  ) {
    return this.usersService.updateProfile(user.id, updateProfileDto);
  }

  @Delete('profile')
  @ApiOperation({ summary: 'Desactivar mi cuenta' })
  deactivateAccount(@CurrentUser() user: JwtPayload) {
    return this.usersService.deactivateAccount(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Ver perfil público de un usuario' })
  getPublicProfile(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.usersService.getPublicProfile(id, user.id);
  }

  @Get(':id/followers')
  @ApiOperation({ summary: 'Ver seguidores de un usuario' })
  getFollowers(@Param('id', ParseUUIDPipe) id: string) {
    return this.usersService.getFollowers(id);
  }

  @Get(':id/following')
  @ApiOperation({ summary: 'Ver a quiénes sigue un usuario' })
  getFollowing(@Param('id', ParseUUIDPipe) id: string) {
    return this.usersService.getFollowing(id);
  }

  @Post(':id/follow')
  @ApiOperation({ summary: 'Seguir a un colaborador' })
  follow(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.usersService.follow(user.id, id);
  }

  @Delete(':id/follow')
  @ApiOperation({ summary: 'Dejar de seguir a un colaborador' })
  unfollow(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.usersService.unfollow(user.id, id);
  }
}