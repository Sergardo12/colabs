import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { BaseEntity } from 'src/common/entities/base.entity';

@Entity('user_providers')
export class UserProvider extends BaseEntity {

  @Column({ name: 'user_id' })
  userId!: string;

  @Column()
  provider!: string;

  @Column({ name: 'provider_id', nullable: true })
  providerId!: string;

  @Column({ name: 'password_hash', nullable: true, select: false })
  passwordHash!: string;

  @ManyToOne(() => User, (user) => user.providers)
  @JoinColumn({ name: 'user_id' })
  user!: User;
}