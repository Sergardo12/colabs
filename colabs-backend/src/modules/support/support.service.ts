import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Support } from './entities/support.entity';
import { CreateSupportDto } from './dto/create-support.dto';

@Injectable()
export class SupportService {
  constructor(
    @InjectRepository(Support)
    private supportRepository: Repository<Support>,
  ) {}

  async create(userId: string, dto: CreateSupportDto) {
    const support = this.supportRepository.create({
      userId,
      description: dto.description,
      status: 'pending',
    });

    return this.supportRepository.save(support);
  }

  async findMyTickets(userId: string) {
    return this.supportRepository.find({
      where: { userId },
      order: { date: 'DESC' },
    });
  }
}