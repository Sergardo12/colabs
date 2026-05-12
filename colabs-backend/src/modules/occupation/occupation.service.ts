import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Occupation } from './entities/occupation.entity';
import { CreateOccupationDto } from './dto/create-occupation.dto';
import { UpdateOccupationDto } from './dto/update-occupation.dto';

@Injectable()
export class OccupationService {
  constructor(
    @InjectRepository(Occupation)
    private occupationRepository: Repository<Occupation>,
  ) {}

  async findAll() {
    return this.occupationRepository.find({
      where: { status: 'active' },
      order: { name: 'ASC' },
    });
  }

  async findOne(id: string) {
    const occupation = await this.occupationRepository.findOne({
      where: { id },
    });

    if (!occupation) {
      throw new NotFoundException(`Oficio con id ${id} no encontrado`);
    }

    return occupation;
  }

  async create(createOccupationDto: CreateOccupationDto) {
    const existing = await this.occupationRepository.findOne({
      where: { name: createOccupationDto.name },
    });

    if (existing) {
      throw new ConflictException(`El oficio "${createOccupationDto.name}" ya existe`);
    }

    const occupation = this.occupationRepository.create(createOccupationDto);
    return this.occupationRepository.save(occupation);
  }

  async update(id: string, updateOccupationDto: UpdateOccupationDto) {
    const occupation = await this.findOne(id);
    Object.assign(occupation, updateOccupationDto);
    return this.occupationRepository.save(occupation);
  }

  async remove(id: string) {
    const occupation = await this.findOne(id);
    occupation.status = 'inactive';
    return this.occupationRepository.save(occupation);
  }
}