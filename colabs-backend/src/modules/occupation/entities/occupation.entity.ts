import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToMany,
  OneToMany
} from 'typeorm';
import { ProfileColab } from '../../profile-colab/entities/profile-colab.entity';
import { ServiceRequest } from 'src/modules/service-request/entities/service-request.entity';
import { BaseEntity } from 'src/common/entities/base.entity';

@Entity('occupations')
export class Occupation extends BaseEntity {

  @Column({ unique: true })
  name!: string;

  @Column({ nullable: true })
  image?: string;

  @ManyToMany(() => ProfileColab, (profile) => profile.occupations)
  profileColabs!: ProfileColab[];

  @OneToMany(() => ServiceRequest, (sr) => sr.occupation)
  serviceRequests!: ServiceRequest[];
}