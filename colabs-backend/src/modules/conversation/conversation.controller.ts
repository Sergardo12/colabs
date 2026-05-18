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
import { ConversationService } from './conversation.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendMessageDto } from './dto/send-message.dto';
import { AcceptOfferDto } from './dto/accept-offer.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('conversations')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('conversations')
export class ConversationController {
  constructor(private conversationService: ConversationService) {}

  @Post()
  @ApiOperation({ summary: 'Iniciar conversación con un colaborador' })
  create(@Request() req: any, @Body() dto: CreateConversationDto) {
    return this.conversationService.create(req.user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Mis conversaciones' })
  findMyConversations(@Request() req: any) {
    return this.conversationService.findMyConversations(req.user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalle de una conversación' })
  findOne(@Param('id') id: string, @Request() req: any) {
    return this.conversationService.findOne(id, req.user.id);
  }

  @Post(':id/messages')
  @ApiOperation({ summary: 'Enviar mensaje en una conversación' })
  sendMessage(
    @Param('id') id: string,
    @Request() req: any,
    @Body() dto: SendMessageDto,
  ) {
    return this.conversationService.sendMessage(id, req.user.id, dto);
  }

  @Get(':id/messages')
  @ApiOperation({ summary: 'Ver mensajes de una conversación' })
  findMessages(@Param('id') id: string, @Request() req: any) {
    return this.conversationService.findMessages(id, req.user.id);
  }

  @Patch(':id/accept-offer')
  @ApiOperation({ summary: 'Aceptar oferta y crear service request automáticamente' })
  acceptOffer(
    @Param('id') id: string,
    @Request() req: any,
    @Body() dto: AcceptOfferDto,
  ) {
    return this.conversationService.acceptOffer(id, req.user.id, dto);
  }
}