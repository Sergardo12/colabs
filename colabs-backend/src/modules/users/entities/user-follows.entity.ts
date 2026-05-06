import {
  Entity,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  PrimaryColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('user_follows')
export class UserFollows {
  @PrimaryColumn({ name: 'follower_id' })
  followerId!: string;

  @PrimaryColumn({ name: 'following_id' })
  followingId!: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'follower_id' })
  follower!: User;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'following_id' })
  following!: User;
}