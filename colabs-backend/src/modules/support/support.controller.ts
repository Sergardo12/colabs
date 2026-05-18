import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SupportService } from './support.service';
import { CreateSupportDto } from './dto/create-support.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('support')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('support')
export class SupportController {
  constructor(private supportService: SupportService) {}

  @Post()
  @ApiOperation({ summary: 'Abrir ticket de soporte' })
  create(@Request() req: any, @Body() dto: CreateSupportDto) {
    return this.supportService.create(req.user.id, dto);
  }

  @Get('my-tickets')
  @ApiOperation({ summary: 'Mis tickets de soporte' })
  findMyTickets(@Request() req: any) {
    return this.supportService.findMyTickets(req.user.id);
  }
}