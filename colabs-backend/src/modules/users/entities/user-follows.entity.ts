import {
  Entity,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  PrimaryColumn,
} from 'typeorm';
import { User } from './user.entity';
import { BaseEntity } from 'src/common/entities/base.entity';

@Entity('user_follows')
export class UserFollows extends BaseEntity {
  @PrimaryColumn({ name: 'follower_id' })
  followerId!: string;

  @PrimaryColumn({ name: 'following_id' })
  followingId!: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'follower_id' })
  follower!: User;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'following_id' })
  following!: User;
}