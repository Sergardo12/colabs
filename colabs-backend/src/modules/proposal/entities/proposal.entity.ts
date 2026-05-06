import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { ProfileColab } from '../../profile-colab/entities/profile-colab.entity';
import { ServiceRequest } from '../../service-request/entities/service-request.entity';

@Entity('proposals')
export class Proposal {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'profile_colab_id' })
  profileColabId!: string;

  @Column({ name: 'service_request_id' })
  serviceRequestId!: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount!: number;

  @Column({ default: 'pending' })
  status!: string;

  @ManyToOne(() => ProfileColab, (profile) => profile.proposals)
  @JoinColumn({ name: 'profile_colab_id' })
  profileColab!: ProfileColab;

  @ManyToOne(() => ServiceRequest, (sr) => sr.proposals)
  @JoinColumn({ name: 'service_request_id' })
  serviceRequest!: ServiceRequest;
}