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
import { ProposalService } from './proposal.service';
import { CreateProposalDto } from './dto/create-proposal.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('proposals')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('proposals')
export class ProposalController {
  constructor(private proposalService: ProposalService) {}

  @Post()
  @ApiOperation({ summary: 'Enviar propuesta (colaborador)' })
  create(@Request() req: any, @Body() dto: CreateProposalDto) {
    return this.proposalService.create(req.user.id, dto);
  }

  @Get('my-proposals')
  @ApiOperation({ summary: 'Mis propuestas como colaborador' })
  findMyProposals(@Request() req: any) {
    return this.proposalService.findMyProposals(req.user.id);
  }

  @Get('request/:requestId')
  @ApiOperation({ summary: 'Propuestas de una solicitud (demandante)' })
  findByServiceRequest(
    @Param('requestId') requestId: string,
    @Request() req: any,
  ) {
    return this.proposalService.findByServiceRequest(requestId, req.user.id);
  }

  @Patch(':id/accept')
  @ApiOperation({ summary: 'Aceptar una propuesta (demandante)' })
  accept(@Param('id') id: string, @Request() req: any) {
    return this.proposalService.accept(id, req.user.id);
  }

  @Patch(':id/reject')
  @ApiOperation({ summary: 'Rechazar una propuesta (demandante)' })
  reject(@Param('id') id: string, @Request() req: any) {
    return this.proposalService.reject(id, req.user.id);
  }
}