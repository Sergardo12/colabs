import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { ProfileColab } from '../../profile-colab/entities/profile-colab.entity';
import { Post } from '../../post/entities/post.entity';
import { ServiceRequest } from '../../service-request/entities/service-request.entity';
import { Message } from '../../message/entities/message.entity';
import { BaseEntity } from 'src/common/entities/base.entity';

@Entity('conversations')
export class Conversation extends BaseEntity {

  @Column({ name: 'user_id' })
  userId!: string;

  @Column({ name: 'profile_colab_id' })
  profileColabId!: string;

  @Column({ name: 'post_id', nullable: true })
  postId?: string;

  @Column({ name: 'service_request_id', nullable: true })
  serviceRequestId?: string;


  @Column({ name: 'expires_at', nullable: true })
  expiresAt?: Date;


  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @ManyToOne(() => ProfileColab)
  @JoinColumn({ name: 'profile_colab_id' })
  profileColab!: ProfileColab;

  @ManyToOne(() => Post, { nullable: true })
  @JoinColumn({ name: 'post_id' })
  post?: Post;

  @ManyToOne(() => ServiceRequest, { nullable: true })
  @JoinColumn({ name: 'service_request_id' })
  serviceRequest?: ServiceRequest;

  @OneToMany(() => Message, (message) => message.conversation)
  messages!: Message[];
}