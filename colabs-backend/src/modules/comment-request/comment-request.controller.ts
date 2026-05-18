import {
  Controller,
  Get,
  Post,
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
import { CommentRequestService } from './comment-request.service';
import { CreateCommentRequestDto } from './dto/create-comment-request.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('comment-requests')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('comment-requests')
export class CommentRequestController {
  constructor(private commentRequestService: CommentRequestService) {}

  @Post()
  @ApiOperation({ summary: 'Calificar un servicio completado' })
  create(@Request() req: any, @Body() dto: CreateCommentRequestDto) {
    return this.commentRequestService.create(req.user.id, dto);
  }

  @Get('my-reviews')
  @ApiOperation({ summary: 'Mis calificaciones como demandante' })
  findMyReviews(@Request() req: any) {
    return this.commentRequestService.findMyReviews(req.user.id);
  }

  @Get('colab/:profileColabId')
  @ApiOperation({ summary: 'Calificaciones de un colaborador' })
  findByProfileColab(@Param('profileColabId') profileColabId: string) {
    return this.commentRequestService.findByProfileColab(profileColabId);
  }
}