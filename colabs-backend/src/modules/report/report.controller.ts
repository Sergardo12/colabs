import { Controller, Get, Post, Body, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
} from '@nestjs/swagger';
import { ReportService } from './report.service';
import { CreateReportDto } from './dto/create-report.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from 'src/common/decorators/current-user.decorator';
import type { JwtPayload } from 'src/common/interfaces/jwt-payload.interface';

@ApiTags('reports')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('reports')
export class ReportController {
  constructor(private reportService: ReportService) {}

  @Post()
  @ApiOperation({ summary: 'Reportar un usuario' })
  @ApiResponse({
    status: 409,
    description: 'El servicio ya fue reportado previamente',
    schema: {
      example: {
        statusCode: 409,
        message: 'Este servicio ya fue reportado',
        path: '/api/reports',
        timestamp: '2026-11-19T12:34:56.789Z',
      },
    },
  })
  create(@CurrentUser() user: JwtPayload, @Body() dto: CreateReportDto) {
    return this.reportService.create(user.id, dto);
  }

  @Get('my-reports')
  @ApiOperation({ summary: 'Mis reportes enviados' })
  findMyReports(@CurrentUser() user: JwtPayload) {
    return this.reportService.findMyReports(user.id);
  }
}
