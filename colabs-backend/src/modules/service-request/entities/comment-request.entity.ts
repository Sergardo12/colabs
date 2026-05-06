import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { ServiceRequest } from './service-request.entity';

@Entity('comment_requests')
export class CommentRequest {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'user_id' })
  userId!: string;

  @Column({ name: 'service_request_id' })
  serviceRequestId!: string;

  @Column({ nullable: true })
  comment?: string;

  @Column({ type: 'int', nullable: true })
  rating?: number;

  @CreateDateColumn({ name: 'creation_date' })
  creationDate!: Date;

  @Column({ default: 'active' })
  status!: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @OneToOne(() => ServiceRequest, (sr) => sr.commentRequest)
  @JoinColumn({ name: 'service_request_id' })
  serviceRequest!: ServiceRequest;
}