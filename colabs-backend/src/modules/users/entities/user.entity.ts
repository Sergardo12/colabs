import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { ProfileColab } from '../../profile-colab/entities/profile-colab.entity';
import { UserProvider } from './user-provider.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ unique: true })
  email!: string;

  @Column()
  name!: string;

  @Column({ name: 'last_name' })
  lastName!: string;

  @Column({ name: 'phone_number', nullable: true })
  phoneNumber!: string;

  @Column({ name: 'image_profile', nullable: true })
  imageProfile!: string;

  @Column({ name: 'date_birth', type: 'date', nullable: true })
  dateBirth!: Date;

  @Column({ nullable: true })
  gender!: string;

  @CreateDateColumn({ name: 'registration_date' })
  registrationDate!: Date;

  @Column({ default: 'active' })
  status!: string;

  @OneToMany(() => UserProvider, (provider) => provider.user)
  providers!: UserProvider[];

  @OneToOne(() => ProfileColab, (profile) => profile.user)
  profileColab!: ProfileColab;
}