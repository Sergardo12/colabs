import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
  Query,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { PostService } from './post.service';
import { CreatePostDto } from './dto/create-post.dto';
import { CreatePostCommentDto } from './dto/create-post-comment.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('posts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('posts')
export class PostController {
  constructor(private postService: PostService) {}

  @Post()
  @ApiOperation({ summary: 'Crear post (solo colaborador)' })
  create(@Request() req: any, @Body() dto: CreatePostDto) {
    return this.postService.create(req.user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Feed de posts' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  findFeed(
    @Request() req: any,
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 10,
  ) {
    return this.postService.findFeed(req.user.id, +page, +limit);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalle de un post' })
  findOne(@Param('id') id: string, @Request() req: any) {
    return this.postService.findOne(id, req.user.id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar mi post (soft delete)' })
  remove(@Param('id') id: string, @Request() req: any) {
    return this.postService.remove(id, req.user.id);
  }

  @Post(':id/like')
  @ApiOperation({ summary: 'Dar like a un post' })
  like(@Param('id') id: string, @Request() req: any) {
    return this.postService.like(id, req.user.id);
  }

  @Delete(':id/like')
  @ApiOperation({ summary: 'Quitar like de un post' })
  unlike(@Param('id') id: string, @Request() req: any) {
    return this.postService.unlike(id, req.user.id);
  }

  @Post(':id/comments')
  @ApiOperation({ summary: 'Comentar un post' })
  addComment(
    @Param('id') id: string,
    @Request() req: any,
    @Body() dto: CreatePostCommentDto,
  ) {
    return this.postService.addComment(id, req.user.id, dto);
  }

  @Get(':id/comments')
  @ApiOperation({ summary: 'Ver comentarios de un post' })
  findComments(@Param('id') id: string) {
    return this.postService.findComments(id);
  }
}