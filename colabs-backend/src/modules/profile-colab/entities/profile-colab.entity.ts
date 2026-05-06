import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  OneToOne,
  OneToMany,
  ManyToMany,
  JoinColumn,
  JoinTable,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

import { Post } from '../../post/entities/post.entity';
import { Occupation } from 'src/modules/occupation/entities/occupation.entity';
import { Proposal } from 'src/modules/proposal/entities/proposal.entity';

@Entity('profile_colab')
export class ProfileColab {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'user_id' })
  userId!: string;

  @Column({ nullable: true })
  description?: string;

  @Column({ nullable: true })
  experience?: string;

  @Column({ nullable: true })
  dni?: string;

  @Column({ name: 'verification_status', default: 'pending' })
  verificationStatus!: string;

  @Column({ default: 'active' })
  status!: string;

  @OneToOne(() => User, (user) => user.profileColab)
  @JoinColumn({ name: 'user_id' })
  user!: User;

  @ManyToMany(() => Occupation, (occupation) => occupation.profileColabs)
  @JoinTable({
    name: 'profile_colab_occupations', // nombre de la tabla intermedia
    joinColumn: { name: 'profile_colab_id' }, // FK hacia esta entidad
    inverseJoinColumn: { name: 'occupation_id' }, // FK hacia Occupation
  })
  occupations!: Occupation[];

  @OneToMany(() => Proposal, (proposal) => proposal.profileColab)
  proposals!: Proposal[];

  @OneToMany(() => Post, (post) => post.profileColab)
  posts!: Post[];
}