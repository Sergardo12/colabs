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
import { ConversationService } from './conversation.service';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { SendMessageDto } from './dto/send-message.dto';
import { AcceptOfferDto } from './dto/accept-offer.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from 'src/common/decorators/current-user.decorator';
import type { JwtPayload } from 'src/common/interfaces/jwt-payload.interface';

@ApiTags('conversations')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('conversations')
export class ConversationController {
  constructor(private conversationService: ConversationService) {}

  @Post()
  @ApiOperation({ summary: 'Iniciar conversación con un colaborador' })
  create(@CurrentUser() user: JwtPayload, @Body() dto: CreateConversationDto) {
    return this.conversationService.create(user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Mis conversaciones' })
  findMyConversations(@CurrentUser() user: JwtPayload) {
    return this.conversationService.findMyConversations(user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalle de una conversación' })
  findOne(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: JwtPayload) {
    return this.conversationService.findOne(id, user.id);
  }

  @Post(':id/messages')
  @ApiOperation({ summary: 'Enviar mensaje en una conversación' })
  sendMessage(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JwtPayload,
    @Body() dto: SendMessageDto,
  ) {
    return this.conversationService.sendMessage(id, user.id, dto);
  }

  @Get(':id/messages')
  @ApiOperation({ summary: 'Ver mensajes de una conversación' })
  findMessages(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: JwtPayload) {
    return this.conversationService.findMessages(id, user.id);
  }

  @Patch(':id/accept-offer')
  @ApiOperation({ summary: 'Aceptar oferta y crear service request automáticamente' })
  acceptOffer(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: JwtPayload,
    @Body() dto: AcceptOfferDto,
  ) {
    return this.conversationService.acceptOffer(id, user.id, dto);
  }
}