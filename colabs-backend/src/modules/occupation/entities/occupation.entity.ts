import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToMany,
  OneToMany,
} from 'typeorm';
import { ProfileColab } from '../../profile-colab/entities/profile-colab.entity';
import { ServiceRequest } from 'src/modules/service-request/entities/service-request.entity';

@Entity('occupations')
export class Occupation {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ unique: true })
  name!: string;

  @Column({ nullable: true })
  image?: string;

  @Column({ default: 'active' })
  status!: string;

  @ManyToMany(() => ProfileColab, (profile) => profile.occupations)
  profileColabs!: ProfileColab[];

  @OneToMany(() => ServiceRequest, (sr) => sr.occupation)
  serviceRequests!: ServiceRequest[];
}