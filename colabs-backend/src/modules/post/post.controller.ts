import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Query,
  ParseUUIDPipe,
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
import { CurrentUser } from 'src/common/decorators/current-user.decorator';

@ApiTags('posts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('posts')
export class PostController {
  constructor(private postService: PostService) {}

  @Post()
  @ApiOperation({ summary: 'Crear post (solo colaborador)' })
  create(@CurrentUser() user: any, @Body() dto: CreatePostDto) {
    return this.postService.create(user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Feed de posts' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'profileColabId', required: false, type: String })
  findFeed(
    @CurrentUser() user: any,
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 10,
    @Query('profileColabId') profileColabId?: string,
  ) {
    return this.postService.findFeed(user.id, +page, +limit, profileColabId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Detalle de un post' })
  findOne(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: any) {
    return this.postService.findOne(id, user.id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar mi post (soft delete)' })
  remove(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: any) {
    return this.postService.remove(id, user.id);
  }

  @Post(':id/like')
  @ApiOperation({ summary: 'Dar like a un post' })
  like(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: any) {
    return this.postService.like(id, user.id);
  }

  @Delete(':id/like')
  @ApiOperation({ summary: 'Quitar like de un post' })
  unlike(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: any) {
    return this.postService.unlike(id, user.id);
  }

  @Post(':id/comments')
  @ApiOperation({ summary: 'Comentar un post' })
  addComment(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: any,
    @Body() dto: CreatePostCommentDto,
  ) {
    return this.postService.addComment(id, user.id, dto);
  }

  @Get(':id/comments')
  @ApiOperation({ summary: 'Ver comentarios de un post' })
  findComments(@Param('id', ParseUUIDPipe) id: string) {
    return this.postService.findComments(id);
  }
}