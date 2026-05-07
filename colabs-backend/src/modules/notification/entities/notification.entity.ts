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

@Entity('notifications')
export class Notification extends BaseEntity {

  @Column({ name: 'user_id' })
  userId!: string;

  @Column({ name: 'admin_sender_id', nullable: true })
  adminSenderId?: string;

  @Column()
  type!: string;

  @Column()
  title!: string;

  @Column({ nullable: true })
  body?: string;

  @Column({ name: 'entity_type', nullable: true })
  entityType?: string;

  @Column({ name: 'entity_id', nullable: true })
  entityId?: string;

  @Column({ name: 'is_read', default: false })
  isRead!: boolean;

  @CreateDateColumn({ name: 'creation_date' })
  creationDate!: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @ManyToOne(() => AdminUser, { nullable: true })
  @JoinColumn({ name: 'admin_sender_id' })
  adminSender?: AdminUser;
}