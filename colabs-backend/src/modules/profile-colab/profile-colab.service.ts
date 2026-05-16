import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProfileColab } from './entities/profile-colab.entity';
import { Occupation } from '../occupation/entities/occupation.entity';
import { User } from '../users/entities/user.entity';
import { CreateProfileColabDto } from './dto/create-profile-colab.dto';
import { UpdateProfileColabDto } from './dto/update-profile-colab.dto';

@Injectable()
export class ProfileColabService {
  constructor(
    @InjectRepository(ProfileColab)
    private profileColabRepository: Repository<ProfileColab>,

    @InjectRepository(Occupation)
    private occupationRepository: Repository<Occupation>,

    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async create(userId: string, dto: CreateProfileColabDto) {
    // Verificar que no tenga ya un perfil colaborador
    const existing = await this.profileColabRepository.findOne({
      where: { userId },
    });

    if (existing) {
      throw new ConflictException('Ya tienes un perfil de colaborador');
    }

    // Verificar que las ocupaciones existen
    const occupations = await this.occupationRepository
      .createQueryBuilder('occupation')
      .where('occupation.id IN (:...ids)', { ids: dto.occupationIds })
      .andWhere('occupation.status = :status', { status: 'active' })
      .getMany();

    if (occupations.length !== dto.occupationIds.length) {
      throw new BadRequestException('Una o más ocupaciones no son válidas');
    }

    // Crear el perfil colaborador
    const profileColab = this.profileColabRepository.create({
      userId,
      description: dto.description,
      experience: dto.experience,
      dni: dto.dni,
      dniImage: dto.dniImage,
      certifications: dto.certifications,
      verificationStatus: 'pending',
      occupations,
    });

    return this.profileColabRepository.save(profileColab);
  }

  async getMyProfile(userId: string) {
    const profile = await this.profileColabRepository.findOne({
      where: { userId },
      relations: ['occupations'],
    });

    if (!profile) {
      throw new NotFoundException('No tienes un perfil de colaborador');
    }

    return profile;
  }

  async update(userId: string, dto: UpdateProfileColabDto) {
    const profile = await this.profileColabRepository.findOne({
      where: { userId },
      relations: ['occupations'],
    });

    if (!profile) {
      throw new NotFoundException('No tienes un perfil de colaborador');
    }

    // Si viene nuevas ocupaciones las actualizamos
    if (dto.occupationIds) {
      const occupations = await this.occupationRepository
        .createQueryBuilder('occupation')
        .where('occupation.id IN (:...ids)', { ids: dto.occupationIds })
        .andWhere('occupation.status = :status', { status: 'active' })
        .getMany();

      if (occupations.length !== dto.occupationIds.length) {
        throw new BadRequestException('Una o más ocupaciones no son válidas');
      }

      profile.occupations = occupations;
    }

    Object.assign(profile, {
      description: dto.description ?? profile.description,
      experience: dto.experience ?? profile.experience,
      dni: dto.dni ?? profile.dni,
      dniImage: dto.dniImage ?? profile.dniImage,
      certifications: dto.certifications ?? profile.certifications,
    });

    return this.profileColabRepository.save(profile);
  }
}