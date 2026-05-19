import {
  Controller,
  Get,
  Post,
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
import { CommentRequestService } from './comment-request.service';
import { CreateCommentRequestDto } from './dto/create-comment-request.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from 'src/common/decorators/current-user.decorator';
import type { JwtPayload } from 'src/common/interfaces/jwt-payload.interface';

@ApiTags('comment-requests')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('comment-requests')
export class CommentRequestController {
  constructor(private commentRequestService: CommentRequestService) {}

  @Post()
  @ApiOperation({ summary: 'Calificar un servicio completado' })
  create(@CurrentUser() user: JwtPayload, @Body() dto: CreateCommentRequestDto) {
    return this.commentRequestService.create(user.id, dto);
  }

  @Get('my-reviews')
  @ApiOperation({ summary: 'Mis calificaciones como demandante' })
  findMyReviews(@CurrentUser() user: JwtPayload) {
    return this.commentRequestService.findMyReviews(user.id);
  }

  @Get('colab/:profileColabId')
  @ApiOperation({ summary: 'Calificaciones de un colaborador' })
  findByProfileColab(@Param('profileColabId', ParseUUIDPipe) profileColabId: string) {
    return this.commentRequestService.findByProfileColab(profileColabId);
  }
}