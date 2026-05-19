import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SupportService } from './support.service';
import { CreateSupportDto } from './dto/create-support.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from 'src/common/decorators/current-user.decorator';
import type { JwtPayload } from 'src/common/interfaces/jwt-payload.interface';

@ApiTags('support')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('support')
export class SupportController {
  constructor(private supportService: SupportService) {}

  @Post()
  @ApiOperation({ summary: 'Abrir ticket de soporte' })
  create(@CurrentUser() user: JwtPayload, @Body() dto: CreateSupportDto) {
    return this.supportService.create(user.id, dto);
  }

  @Get('my-tickets')
  @ApiOperation({ summary: 'Mis tickets de soporte' })
  findMyTickets(@CurrentUser() user: JwtPayload) {
    return this.supportService.findMyTickets(user.id);
  }
}