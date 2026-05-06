import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Occupation } from '../../occupation/entities/occupation.entity';
import { Proposal } from 'src/modules/proposal/entities/proposal.entity';
import { CommentRequest } from './comment-request.entity';


@Entity('service_requests')
export class ServiceRequest {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'user_id' })
  userId!: string;

  @Column({ name: 'occupation_id' })
  occupationId!: string;

  @Column({ type: 'geography', spatialFeatureType: 'Point', srid: 4326, nullable: true })
  location?: string;

  @Column({ nullable: true })
  direction?: string;

  @Column({ nullable: true })
  description?: string;

  @CreateDateColumn({ name: 'creation_date' })
  creationDate!: Date;

  @Column({ name: 'acceptance_date', nullable: true })
  acceptanceDate?: Date;

  @Column({ name: 'completion_date', nullable: true })
  completionDate?: Date;

  @Column({ default: 'pending' })
  status!: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @ManyToOne(() => Occupation, (occupation) => occupation.serviceRequests)
  @JoinColumn({ name: 'occupation_id' })
  occupation!: Occupation;

  @OneToMany(() => Proposal, (proposal) => proposal.serviceRequest)
  proposals!: Proposal[];

  @OneToOne(() => CommentRequest, (comment) => comment.serviceRequest)
  commentRequest?: CommentRequest;
}