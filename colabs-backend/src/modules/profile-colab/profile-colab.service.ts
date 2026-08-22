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
import { CommentRequest } from '../service-request/entities/comment-request.entity';
import { Proposal } from '../proposal/entities/proposal.entity';
import { CreateProfileColabDto } from './dto/create-profile-colab.dto';
import { UpdateProfileColabDto } from './dto/update-profile-colab.dto';
import { RedisService } from 'src/common/services/redis.service';

@Injectable()
export class ProfileColabService {
  constructor(
    @InjectRepository(ProfileColab)
    private profileColabRepository: Repository<ProfileColab>,

    @InjectRepository(Occupation)
    private occupationRepository: Repository<Occupation>,

    @InjectRepository(User)
    private userRepository: Repository<User>,

    private redisService: RedisService,
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

 async search(
  page: number = 1,
  limit: number = 10,
  query?: string,
  name?: string,
  occupation?: string,
) {
  const qb = this.profileColabRepository
    .createQueryBuilder('profile')
    .leftJoinAndSelect('profile.user', 'user')
    .leftJoinAndSelect('profile.occupations', 'occupation')
    .where('profile.status = :status', { status: 'active' })
    .addSelect(
      (sub) =>
        sub
          .select('AVG(cr.rating)', 'avg_rating')
          .from(CommentRequest, 'cr')
          .innerJoin(Proposal, 'p', 'p.service_request_id = cr.service_request_id')
          .where('p.profile_colab_id = profile.id')
          .andWhere('cr.status = :status', { status: 'active' }),
      'avg_rating',
    );

  if (query) {
    // query tiene prioridad — busca en nombre, apellido y ocupación
    qb.andWhere(
      '(LOWER(user.name) LIKE :q OR LOWER(user.last_name) LIKE :q OR LOWER(occupation.name) LIKE :q)',
      { q: `%${query.toLowerCase()}%` },
    );
  } else {
    // filtros individuales para compatibilidad
    if (name) {
      qb.andWhere(
        '(LOWER(user.name) LIKE :name OR LOWER(user.last_name) LIKE :name)',
        { name: `%${name.toLowerCase()}%` },
      );
    }
    if (occupation) {
      qb.andWhere('LOWER(occupation.name) LIKE :occupation', {
        occupation: `%${occupation.toLowerCase()}%`,
      });
    }
  }

  const total = await qb.getCount();

  const { entities, raw } = await qb
    .skip((page - 1) * limit)
    .take(limit)
    .getRawAndEntities();

  return {
    data: entities.map((profile, i) => ({
      id: profile.id,
      userId: profile.userId,
      description: profile.description,
      experience: profile.experience,
      verificationStatus: profile.verificationStatus,
      avgRating: Math.round(Number(raw[i]?.avg_rating ?? 0) * 10) / 10,
      occupations: profile.occupations.map(o => ({
        id: o.id,
        name: o.name,
        image: o.image,
      })),
      user: {
        id: profile.user.id,
        name: profile.user.name,
        lastName: profile.user.lastName,
        imageProfile: profile.user.imageProfile,
      },
    })),
    total,
    page,
    lastPage: Math.ceil(total / limit),
  };
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

  async updateLocation(
  userId: string,
  lat: number,
  lng: number,
) {
  const profile = await this.profileColabRepository.findOne({
    where: { userId },
    relations: ['occupations'],
  });

  if (!profile) {
    throw new NotFoundException('No tienes perfil de colaborador');
  }

  const occupationIds = profile.occupations.map(o => o.id);

  await this.redisService.setCollaboratorLocation(
    userId,
    lat,
    lng,
    occupationIds,
  );

  return { message: 'Ubicación actualizada', status: 'available' };
}

async deactivateLocation(userId: string) {
  await this.redisService.removeCollaboratorLocation(userId);
  return { message: 'Disponibilidad desactivada', status: 'offline' };
}
}