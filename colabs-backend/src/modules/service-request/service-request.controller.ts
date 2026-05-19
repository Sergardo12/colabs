import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  Param,
  UseGuards,
  ParseUUIDPipe,
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
  create(@CurrentUser() user: JwtPayload, @Body() dto: CreateServiceRequestDto) {
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

  @Get(':id')
  @ApiOperation({ summary: 'Detalle de una solicitud' })
  findOne(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: JwtPayload) {
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
}