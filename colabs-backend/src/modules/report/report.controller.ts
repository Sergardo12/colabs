import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ReportService } from './report.service';
import { CreateReportDto } from './dto/create-report.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('reports')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('reports')
export class ReportController {
  constructor(private reportService: ReportService) {}

  @Post()
  @ApiOperation({ summary: 'Reportar un usuario' })
  create(@Request() req: any, @Body() dto: CreateReportDto) {
    return this.reportService.create(req.user.id, dto);
  }

  @Get('my-reports')
  @ApiOperation({ summary: 'Mis reportes enviados' })
  findMyReports(@Request() req: any) {
    return this.reportService.findMyReports(req.user.id);
  }
}