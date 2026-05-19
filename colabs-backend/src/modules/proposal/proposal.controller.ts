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
import { ProposalService } from './proposal.service';
import { CreateProposalDto } from './dto/create-proposal.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from 'src/common/decorators/current-user.decorator';
import type { JwtPayload } from 'src/common/interfaces/jwt-payload.interface';

@ApiTags('proposals')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('proposals')
export class ProposalController {
  constructor(private proposalService: ProposalService) {}

  @Post()
  @ApiOperation({ summary: 'Enviar propuesta (colaborador)' })
  create(@CurrentUser() user: JwtPayload, @Body() dto: CreateProposalDto) {
    return this.proposalService.create(user.id, dto);
  }

  @Get('my-proposals')
  @ApiOperation({ summary: 'Mis propuestas como colaborador' })
  findMyProposals(@CurrentUser() user: JwtPayload) {
    return this.proposalService.findMyProposals(user.id);
  }

  @Get('request/:requestId')
  @ApiOperation({ summary: 'Propuestas de una solicitud (demandante)' })
  findByServiceRequest(
    @Param('requestId', ParseUUIDPipe) requestId: string,
    @CurrentUser() user: JwtPayload,
  ) {
    return this.proposalService.findByServiceRequest(requestId, user.id);
  }

  @Patch(':id/accept')
  @ApiOperation({ summary: 'Aceptar una propuesta (demandante)' })
  accept(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: JwtPayload) {
    return this.proposalService.accept(id, user.id);
  }

  @Patch(':id/reject')
  @ApiOperation({ summary: 'Rechazar una propuesta (demandante)' })
  reject(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: JwtPayload) {
    return this.proposalService.reject(id, user.id);
  }
}