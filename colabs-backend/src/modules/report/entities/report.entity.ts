import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { ServiceRequest } from '../../service-request/entities/service-request.entity';
import { AdminUser } from '../../admin/entities/admin-user.entity';
import { BaseEntity } from 'src/common/entities/base.entity';

@Entity('reports')
export class Report extends BaseEntity {

  @Column({ name: 'reporter_id' })
  reporterId!: string;

  @Column({ name: 'reported_user_id' })
  reportedUserId!: string;

  @Column({ name: 'service_request_id', nullable: true })
  serviceRequestId?: string;

  @Column({ name: 'admin_user_id', nullable: true })
  adminUserId?: string;

  @Column()
  category!: string;

  @CreateDateColumn()
  date!: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'reporter_id' })
  reporter!: User;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'reported_user_id' })
  reportedUser!: User;

  @ManyToOne(() => ServiceRequest, { nullable: true })
  @JoinColumn({ name: 'service_request_id' })
  serviceRequest?: ServiceRequest;

  @ManyToOne(() => AdminUser, { nullable: true })
  @JoinColumn({ name: 'admin_user_id' })
  adminUser?: AdminUser;
}