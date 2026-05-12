import {
  Controller,
  Get,
  Patch,
  Delete,
  Post,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('profile')
  @ApiOperation({ summary: 'Ver mi perfil completo' })
  getMyProfile(@Request() req: any) {
    return this.usersService.getMyProfile(req.user.id);
  }

  @Patch('profile')
  @ApiOperation({ summary: 'Actualizar mi perfil' })
  updateProfile(
    @Request() req: any,
    @Body() updateProfileDto: UpdateProfileDto,
  ) {
    return this.usersService.updateProfile(req.user.id, updateProfileDto);
  }

  @Delete('profile')
  @ApiOperation({ summary: 'Desactivar mi cuenta' })
  deactivateAccount(@Request() req: any) {
    return this.usersService.deactivateAccount(req.user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Ver perfil público de un usuario' })
  getPublicProfile(
    @Param('id') id: string,
    @Request() req: any,
  ) {
    return this.usersService.getPublicProfile(id, req.user.id);
  }

  @Get(':id/followers')
  @ApiOperation({ summary: 'Ver seguidores de un usuario' })
  getFollowers(@Param('id') id: string) {
    return this.usersService.getFollowers(id);
  }

  @Get(':id/following')
  @ApiOperation({ summary: 'Ver a quiénes sigue un usuario' })
  getFollowing(@Param('id') id: string) {
    return this.usersService.getFollowing(id);
  }

  @Post(':id/follow')
  @ApiOperation({ summary: 'Seguir a un colaborador' })
  follow(
    @Param('id') id: string,
    @Request() req: any,
  ) {
    return this.usersService.follow(req.user.id, id);
  }

  @Delete(':id/follow')
  @ApiOperation({ summary: 'Dejar de seguir a un colaborador' })
  unfollow(
    @Param('id') id: string,
    @Request() req: any,
  ) {
    return this.usersService.unfollow(req.user.id, id);
  }
}