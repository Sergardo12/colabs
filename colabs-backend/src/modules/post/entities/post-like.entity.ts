import {
  Entity,
  ManyToOne,
  JoinColumn,
  Column,
  CreateDateColumn,
  PrimaryColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Post } from './post.entity';
import { BaseEntity } from 'src/common/entities/base.entity';

@Entity('post_likes')
export class PostLike extends BaseEntity {

  @PrimaryColumn({ name: 'user_id' })
  userId!: string;

  @PrimaryColumn({ name: 'post_id' })
  postId!: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @ManyToOne(() => Post, (post) => post.likes)
  @JoinColumn({ name: 'post_id' })
  post!: Post;
}