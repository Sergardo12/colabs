import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  Query,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ServiceRequestService } from './service-request.service';
import { CreateServiceRequestDto } from './dto/create-service-request.dto';
import { UpdateServiceRequestStatusDto } from './dto/update-service-request-status.dto';
import { GetCancelledWithColabQueryDto } from './dto/get-cancelled-with-colab-query.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from 'src/common/decorators/current-user.decorator';
import type { JwtPayload } from 'src/common/interfaces/jwt-payload.interface';

@ApiTags('service-requests')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('service-requests')
export class ServiceRequestController {
  constructor(private serviceRequestService: ServiceRequestService) {}

  @Post()
  @ApiOperation({ summary: 'Crear solicitud de servicio (demandante)' })
  create(
    @CurrentUser() user: JwtPayload,
    @Body() dto: CreateServiceRequestDto,
  ) {
    return this.serviceRequestService.create(user.id, dto);
  }

  @Get('my-requests')
  @ApiOperation({ summary: 'Mis solicitudes como demandante' })
  findMyRequests(@CurrentUser() user: JwtPayload) {
    return this.serviceRequestService.findMyRequests(user.id);
  }

  @Get('nearby')
  @ApiOperation({ summary: 'Solicitudes cercanas (colaborador activo)' })
  findNearby(@CurrentUser() user: JwtPayload) {
    return this.serviceRequestService.findNearby(user.id);
  }

  @Get('cancelled-with-colab')
  @ApiOperation({
    summary:
      'Servicios cancelados con colaborador ganador (para reportar al colaborador)',
  })
  findCancelledWithColab(
    @CurrentUser() user: JwtPayload,
    @Query() query: GetCancelledWithColabQueryDto,
  ) {
    return this.serviceRequestService.findCancelledWithColab(
      user.id,
      query.search,
    );
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalle de una solicitud' })
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.serviceRequestService.findOne(id, user.id);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Actualizar estado de solicitud' })
  updateStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JwtPayload,
    @Body() dto: UpdateServiceRequestStatusDto,
  ) {
    return this.serviceRequestService.updateStatus(id, user.id, dto);
  }

  @Patch(':id/start')
  @ApiOperation({
    summary: 'Iniciar trabajo (colaborador ganador: accepted → in_progress)',
  })
  startWork(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.serviceRequestService.startWork(id, user.id);
  }

  @Patch(':id/complete')
  @ApiOperation({
    summary:
      'Finalizar servicio (colaborador ganador: in_progress → completed)',
  })
  completeWork(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.serviceRequestService.completeWork(id, user.id);
  }

  @Patch(':id/cancel')
  @ApiOperation({
    summary:
      'Cancelar servicio pendiente o aceptado (dueño; en aceptado también colaborador ganador)',
  })
  cancel(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.serviceRequestService.cancel(id, user.id);
  }

  @Post(':id/reload')
  @ApiOperation({
    summary:
      'Volver a abrir un servicio cancelado creando uno nuevo en pending',
  })
  reload(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.serviceRequestService.reload(id, user.id);
  }
}
