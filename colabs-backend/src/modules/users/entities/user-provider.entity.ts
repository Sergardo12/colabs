import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('user_providers')
export class UserProvider {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

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