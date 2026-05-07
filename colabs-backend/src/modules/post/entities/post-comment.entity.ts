import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Post } from './post.entity';
import { BaseEntity } from 'src/common/entities/base.entity';

@Entity('post_comments')
export class PostComment extends BaseEntity {
    
  @Column({ name: 'user_id' })
  userId!: string;

  @Column({ name: 'post_id' })
  postId!: string;

  @Column({ nullable: true })
  comment?: string;

  @CreateDateColumn({ name: 'creation_date' })
  creationDate!: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @ManyToOne(() => Post, (post) => post.comments)
  @JoinColumn({ name: 'post_id' })
  post!: Post;
}