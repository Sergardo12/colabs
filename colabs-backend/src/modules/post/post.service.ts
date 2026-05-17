import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from './entities/post.entity';
import { PostLike } from './entities/post-like.entity';
import { PostComment } from './entities/post-comment.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { CreatePostDto } from './dto/create-post.dto';
import { CreatePostCommentDto } from './dto/create-post-comment.dto';

@Injectable()
export class PostService {
  constructor(
    @InjectRepository(Post)
    private postRepository: Repository<Post>,

    @InjectRepository(PostLike)
    private postLikeRepository: Repository<PostLike>,

    @InjectRepository(PostComment)
    private postCommentRepository: Repository<PostComment>,

    @InjectRepository(ProfileColab)
    private profileColabRepository: Repository<ProfileColab>,
  ) {}

  async create(userId: string, dto: CreatePostDto) {
    const profile = await this.profileColabRepository.findOne({
      where: { userId },
    });

    if (!profile) {
      throw new ForbiddenException('Solo los colaboradores pueden publicar posts');
    }

    const post = this.postRepository.create({
      profileColabId: profile.id,
      description: dto.description,
      media: dto.media ?? [],
      price: dto.price,
      status: 'active',
    });

    return this.postRepository.save(post);
  }

  async findFeed(userId: string, page: number = 1, limit: number = 10) {
    const [posts, total] = await this.postRepository.findAndCount({
      where: { status: 'active' },
      relations: [
        'profileColab',
        'profileColab.user',
        'profileColab.occupations',
        'likes',
        'comments',
      ],
      order: { creationDate: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });

    // Agrega si el usuario actual dio like
    const postsWithLikeStatus = posts.map(post => ({
      ...post,
      likesCount: post.likes.length,
      commentsCount: post.comments.length,
      isLiked: post.likes.some(like => like.userId === userId),
      likes: undefined,    // no mandamos el array completo
      comments: undefined, // no mandamos el array completo
    }));

    return {
      data: postsWithLikeStatus,
      total,
      page,
      lastPage: Math.ceil(total / limit),
    };
  }

  async findOne(id: string, userId: string) {
    const post = await this.postRepository.findOne({
      where: { id, status: 'active' },
      relations: [
        'profileColab',
        'profileColab.user',
        'profileColab.occupations',
        'likes',
        'comments',
        'comments.user',
      ],
    });

    if (!post) throw new NotFoundException('Post no encontrado');

    return {
      ...post,
      likesCount: post.likes.length,
      commentsCount: post.comments.length,
      isLiked: post.likes.some(like => like.userId === userId),
    };
  }

  async remove(id: string, userId: string) {
    const profile = await this.profileColabRepository.findOne({
      where: { userId },
    });

    if (!profile) throw new ForbiddenException('No tienes perfil de colaborador');

    const post = await this.postRepository.findOne({
      where: { id, profileColabId: profile.id },
    });

    if (!post) throw new NotFoundException('Post no encontrado o no te pertenece');

    post.status = 'inactive';
    return this.postRepository.save(post);
  }

  async like(postId: string, userId: string) {
    const post = await this.postRepository.findOne({
      where: { id: postId, status: 'active' },
    });

    if (!post) throw new NotFoundException('Post no encontrado');

    const existing = await this.postLikeRepository.findOne({
      where: { postId, userId },
    });

    if (existing) throw new ForbiddenException('Ya diste like a este post');

    const like = this.postLikeRepository.create({ postId, userId });
    return this.postLikeRepository.save(like);
  }

  async unlike(postId: string, userId: string) {
    const like = await this.postLikeRepository.findOne({
      where: { postId, userId },
    });

    if (!like) throw new NotFoundException('No has dado like a este post');

    return this.postLikeRepository.remove(like);
  }

  async addComment(postId: string, userId: string, dto: CreatePostCommentDto) {
    const post = await this.postRepository.findOne({
      where: { id: postId, status: 'active' },
    });

    if (!post) throw new NotFoundException('Post no encontrado');

    const comment = this.postCommentRepository.create({
      postId,
      userId,
      comment: dto.comment,
    });

    return this.postCommentRepository.save(comment);
  }

  async findComments(postId: string) {
    return this.postCommentRepository.find({
      where: { postId },
      relations: ['user'],
      order: { creationDate: 'DESC' },
    });
  }
}