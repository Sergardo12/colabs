import {
  Controller,
  Post,
  Body,
  Get,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiBody } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { LocalAuthGuard } from './guards/local-auth.guard';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AuthGuard } from '@nestjs/passport';
import { CurrentUser } from 'src/common/decorators/current-user.decorator';
import type { JwtPayload } from 'src/common/interfaces/jwt-payload.interface';
import { User } from '../users/entities/user.entity';
import { GoogleMobileDto } from './dto/google-mobile.dto';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Registro con email y contraseña' })
  register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('login')
  @ApiOperation({ summary: 'Login con email y contraseña' })
  @ApiBody({ type: LoginDto })
  @UseGuards(LocalAuthGuard)
  login(@CurrentUser() user: User) {
    return this.authService.login(user);
  }

  @Get('me')
  @ApiOperation({ summary: 'Obtener usuario autenticado' })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  getMe(@CurrentUser() user: JwtPayload) {
    return this.authService.getMe(user.id);
  }

@Get('google')
@ApiOperation({ summary: 'Login con Google' })
@UseGuards(AuthGuard('google'))
googleAuth() {}

@Get('google/callback')
@UseGuards(AuthGuard('google'))
googleCallback(@CurrentUser() user: any) {
  return user;
}

@Post('google/mobile')
@ApiOperation({ summary: 'Login con Google desde Flutter (mobile)' })
googleMobile(@Body() dto: GoogleMobileDto) {
  return this.authService.validateGoogleMobileToken(dto.idToken);
}
}