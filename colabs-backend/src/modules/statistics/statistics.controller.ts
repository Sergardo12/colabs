import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { CurrentColab } from './decorators/current-colab.decorator';
import { StatisticsPeriodQueryDto } from './dto/statistics-period.query.dto';
import {
  AverageRatingResponseDto,
  MonthlyGoalResponseDto,
  ServicesOfferedResponseDto,
  ServicesRateResponseDto,
  ServicesTotalResponseDto,
} from './dto/statistics-response.dto';
import { UpdateMonthlyGoalDto } from './dto/update-monthly-goal.dto';
import { ColabGuard } from './guards/colab.guard';
import { StatisticsService } from './statistics.service';

@ApiTags('statistics')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, ColabGuard)
@Controller('statistics')
export class StatisticsController {
  constructor(private readonly statisticsService: StatisticsService) {}

  @Get('services-offered')
  @ApiOperation({ summary: 'Servicios ofrecidos agrupados por período' })
  @ApiOkResponse({ type: ServicesOfferedResponseDto })
  getServicesOffered(
    @CurrentColab() profileColab: ProfileColab,
    @Query() query: StatisticsPeriodQueryDto,
  ) {
    return this.statisticsService.getServicesOffered(profileColab, query.period);
  }

  @Get('services-total')
  @ApiOperation({ summary: 'Total de servicios ofrecidos en el período' })
  @ApiOkResponse({ type: ServicesTotalResponseDto })
  getServicesTotal(
    @CurrentColab() profileColab: ProfileColab,
    @Query() query: StatisticsPeriodQueryDto,
  ) {
    return this.statisticsService.getServicesTotal(profileColab, query.period);
  }

  @Get('services-rate')
  @ApiOperation({ summary: 'Tasa histórica de servicios solicitados y ofrecidos' })
  @ApiOkResponse({ type: ServicesRateResponseDto })
  getServicesRate(@CurrentColab() profileColab: ProfileColab) {
    return this.statisticsService.getServicesRate(profileColab);
  }

  @Get('average-rating')
  @ApiOperation({ summary: 'Promedio de calificaciones recibidas' })
  @ApiOkResponse({ type: AverageRatingResponseDto })
  getAverageRating(@CurrentColab() profileColab: ProfileColab) {
    return this.statisticsService.getAverageRating(profileColab);
  }

  @Get('monthly-goal')
  @ApiOperation({ summary: 'Meta del mes actual, o null si no existe' })
  @ApiOkResponse({ type: MonthlyGoalResponseDto })
  getMonthlyGoal(@CurrentColab() profileColab: ProfileColab) {
    return this.statisticsService.getMonthlyGoal(profileColab);
  }

  @Post('monthly-goal')
  @ApiOperation({ summary: 'Crea o actualiza la meta del mes actual' })
  @ApiOkResponse({ type: MonthlyGoalResponseDto })
  saveMonthlyGoal(
    @CurrentColab() profileColab: ProfileColab,
    @Body() dto: UpdateMonthlyGoalDto,
  ) {
    return this.statisticsService.saveMonthlyGoal(profileColab, dto.amount);
  }
}
