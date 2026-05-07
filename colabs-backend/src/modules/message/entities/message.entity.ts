import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Conversation } from '../../conversation/entities/conversation.entity';
import { BaseEntity } from 'src/common/entities/base.entity';

@Entity('messages')
export class Message extends BaseEntity{

  @Column({ name: 'conversation_id' })
  conversationId!: string;

  @Column({ name: 'sender_id' })
  senderId!: string;

  @Column({ nullable: true })
  content?: string;

  @Column({ default: 'text' })
  type!: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  amount?: number;

  @Column({ name: 'is_read', default: false })
  isRead!: boolean;

  @ManyToOne(() => Conversation, (conversation) => conversation.messages)
  @JoinColumn({ name: 'conversation_id' })
  conversation!: Conversation;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'sender_id' })
  sender!: User;
}