import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToMany,
} from 'typeorm';
import { Notification } from '../../notification/entities/notification.entity';
import { Report } from '../../report/entities/report.entity';
import { Suggestion } from '../../suggestion/entities/suggestion.entity';
import { Support } from '../../support/entities/support.entity';

@Entity('admin_users')
export class AdminUser {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column()
  name!: string;

  @Column({ unique: true })
  email!: string;

  @Column({ name: 'password_hash', select: false })
  passwordHash!: string;

  @Column({ name: 'role_admin', default: 'moderator' })
  roleAdmin!: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;

  @Column({ default: 'active' })
  status!: string;

  @OneToMany(() => Notification, (n) => n.adminSender)
  notifications!: Notification[];

  @OneToMany(() => Report, (r) => r.adminUser)
  reports!: Report[];

  @OneToMany(() => Suggestion, (s) => s.adminUser)
  suggestions!: Suggestion[];

  @OneToMany(() => Support, (s) => s.adminUser)
  supports!: Support[];
}