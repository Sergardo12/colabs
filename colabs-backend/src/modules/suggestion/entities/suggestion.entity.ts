import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { AdminUser } from '../../admin/entities/admin-user.entity';
import { BaseEntity } from 'src/common/entities/base.entity';

@Entity('suggestions')
export class Suggestion extends BaseEntity {

  @Column({ name: 'user_id' })
  userId!: string;

  @Column({ name: 'admin_user_id', nullable: true })
  adminUserId?: string;

  @Column({ nullable: true })
  description?: string;

  @CreateDateColumn()
  date!: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @ManyToOne(() => AdminUser, { nullable: true })
  @JoinColumn({ name: 'admin_user_id' })
  adminUser?: AdminUser;
}