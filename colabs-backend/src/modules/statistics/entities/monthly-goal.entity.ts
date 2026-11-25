import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, Unique } from 'typeorm';

@Entity('monthly_goal')
@Unique('UQ_monthly_goal_profile_month_year', ['profileColabId', 'month', 'year'])
export class MonthlyGoal {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @Column({ name: 'profile_colab_id' })
  profileColabId!: string;

  @Column({ type: 'int' })
  month!: number;

  @Column({ type: 'int' })
  year!: number;

  @Column({ type: 'int' })
  amount!: number;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;
}
