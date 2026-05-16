import {
  Controller,
  Get,
  Post,
  Patch,
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
import { ServiceRequestService } from './service-request.service';
import { CreateServiceRequestDto } from './dto/create-service-request.dto';
import { UpdateServiceRequestStatusDto } from './dto/update-service-request-status.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('service-requests')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('service-requests')
export class ServiceRequestController {
  constructor(private serviceRequestService: ServiceRequestService) {}

  @Post()
  @ApiOperation({ summary: 'Crear solicitud de servicio (demandante)' })
  create(@Request() req: any, @Body() dto: CreateServiceRequestDto) {
    return this.serviceRequestService.create(req.user.id, dto);
  }

  @Get('my-requests')
  @ApiOperation({ summary: 'Mis solicitudes como demandante' })
  findMyRequests(@Request() req: any) {
    return this.serviceRequestService.findMyRequests(req.user.id);
  }

  @Get('nearby')
  @ApiOperation({ summary: 'Solicitudes cercanas (colaborador activo)' })
  findNearby(@Request() req: any) {
    return this.serviceRequestService.findNearby(req.user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalle de una solicitud' })
  findOne(@Param('id') id: string, @Request() req: any) {
    return this.serviceRequestService.findOne(id, req.user.id);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Actualizar estado de solicitud' })
  updateStatus(
    @Param('id') id: string,
    @Request() req: any,
    @Body() dto: UpdateServiceRequestStatusDto,
  ) {
    return this.serviceRequestService.updateStatus(id, req.user.id, dto);
  }
}