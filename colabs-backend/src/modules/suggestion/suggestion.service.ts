import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Suggestion } from './entities/suggestion.entity';
import { CreateSuggestionDto } from './dto/create-suggestion.dto';

@Injectable()
export class SuggestionService {
  constructor(
    @InjectRepository(Suggestion)
    private suggestionRepository: Repository<Suggestion>,
  ) {}

  async create(userId: string, dto: CreateSuggestionDto) {
    const suggestion = this.suggestionRepository.create({
      userId,
      description: dto.description,
      status: 'pending',
    });

    return this.suggestionRepository.save(suggestion);
  }

  async findMySuggestions(userId: string) {
    return this.suggestionRepository.find({
      where: { userId },
      order: { date: 'DESC' },
    });
  }
}