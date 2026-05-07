import { PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';

export abstract class BaseEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ default: 'active' })
  status!: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt!: Date;
}