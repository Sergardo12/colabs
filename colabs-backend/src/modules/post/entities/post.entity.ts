import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { ProfileColab } from '../../profile-colab/entities/profile-colab.entity';
import { PostLike } from './post-like.entity';
import { PostComment } from './post-comment.entity';
import { BaseEntity } from 'src/common/entities/base.entity';

@Entity('posts')
export class Post extends BaseEntity {

  @Column({ name: 'profile_colab_id' })
  profileColabId!: string;

  @Column({ nullable: true })
  description?: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  price?: number;

  @Column({ type: 'jsonb', nullable: true })
  media?: string[];

  @CreateDateColumn({ name: 'creation_date' })
  creationDate!: Date;

  @ManyToOne(() => ProfileColab, (profile) => profile.posts)
  @JoinColumn({ name: 'profile_colab_id' })
  profileColab!: ProfileColab;

  @OneToMany(() => PostLike, (like) => like.post)
  likes!: PostLike[];

  @OneToMany(() => PostComment, (comment) => comment.post)
  comments!: PostComment[];
}