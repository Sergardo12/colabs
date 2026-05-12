import {
  Controller,
  Post,
  Body,
  Get,
  UseGuards,
  Request,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiBody } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { LocalAuthGuard } from './guards/local-auth.guard';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AuthGuard } from '@nestjs/passport';

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
  login(@Request() req: any) {
    return this.authService.login(req.user);
  }

  @Get('me')
  @ApiOperation({ summary: 'Obtener usuario autenticado' })
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  getMe(@Request() req: any) {
    return this.authService.getMe(req.user.id);
  }

@Get('google')
@ApiOperation({ summary: 'Login con Google' })
@UseGuards(AuthGuard('google'))
googleAuth() {}

@Get('google/callback')
@UseGuards(AuthGuard('google'))
googleCallback(@Request() req: any) {
  return req.user;
}
}