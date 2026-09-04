import {
  Entity,
  PrimaryColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { ProfileColab } from '../../profile-colab/entities/profile-colab.entity';
import { BaseEntity } from 'src/common/entities/base.entity';

@Entity('profile_colab_favorites')
@Index(
  'uq_profile_colab_favorites_user_profile',
  ['userId', 'profileColabId'],
  { unique: true },
)
export class UserFavorite extends BaseEntity {

  @PrimaryColumn({ name: 'user_id' })
  userId!: string;

  @PrimaryColumn({ name: 'profile_colab_id' })
  profileColabId!: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @ManyToOne(() => ProfileColab)
  @JoinColumn({ name: 'profile_colab_id' })
  profileColab!: ProfileColab;
}
