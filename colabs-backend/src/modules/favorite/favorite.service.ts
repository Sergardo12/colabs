import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserFavorite } from './entities/user-favorite.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { CommentRequest } from '../service-request/entities/comment-request.entity';
import { Proposal } from '../proposal/entities/proposal.entity';

@Injectable()
export class FavoriteService {
  constructor(
    @InjectRepository(UserFavorite)
    private favoriteRepository: Repository<UserFavorite>,

    @InjectRepository(ProfileColab)
    private profileColabRepository: Repository<ProfileColab>,
  ) {}

  async findMyFavorites(userId: string) {
    const favorites = await this.favoriteRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });

    const ids = favorites.map((f) => f.profileColabId);

    if (ids.length === 0) {
      return { data: [] };
    }

    const { entities, raw } = await this.profileColabRepository
      .createQueryBuilder('profile')
      .leftJoinAndSelect('profile.user', 'user')
      .leftJoinAndSelect('profile.occupations', 'occupation')
      .where('profile.id IN (:...ids)', { ids })
      .andWhere('profile.status = :status', { status: 'active' })
      .addSelect(
        (sub) =>
          sub
            .select('AVG(cr.rating)', 'avg_rating')
            .from(CommentRequest, 'cr')
            .innerJoin(
              Proposal,
              'p',
              'p.service_request_id = cr.service_request_id',
            )
            .where('p.profile_colab_id = profile.id')
            .andWhere('cr.status = :status', { status: 'active' }),
        'avg_rating',
      )
      .getRawAndEntities();

    // Mantiene el orden en que fueron agregados — raw[i] alinea con entities[i]
    const byId = new Map(
      entities.map((p, i) => [
        p.id,
        { profile: p, avgRating: Math.round(Number(raw[i]?.avg_rating ?? 0) * 10) / 10 },
      ]),
    );

    const data = ids
      .map((id) => byId.get(id))
      .filter((entry) => entry !== undefined)
      .map((entry) => ({
        id: entry!.profile.id,
        userId: entry!.profile.userId,
        description: entry!.profile.description,
        experience: entry!.profile.experience,
        verificationStatus: entry!.profile.verificationStatus,
        avgRating: entry!.avgRating,
        occupations: entry!.profile.occupations.map((o) => ({
          id: o.id,
          name: o.name,
          image: o.image,
        })),
        user: {
          id: entry!.profile.user.id,
          name: entry!.profile.user.name,
          lastName: entry!.profile.user.lastName,
          imageProfile: entry!.profile.user.imageProfile,
        },
      }));

    return { data };
  }

  async add(userId: string, profileColabId: string) {
    const profile = await this.profileColabRepository.findOne({
      where: { id: profileColabId, status: 'active' },
    });

    if (!profile) {
      throw new NotFoundException('Colaborador no encontrado');
    }

    // Idempotente — si ya es favorito no duplica
    const existing = await this.favoriteRepository.findOne({
      where: { userId, profileColabId },
    });

    if (existing) return existing;

    const favorite = this.favoriteRepository.create({
      userId,
      profileColabId,
    });

    return this.favoriteRepository.save(favorite);
  }

  async remove(userId: string, profileColabId: string) {
    const favorite = await this.favoriteRepository.findOne({
      where: { userId, profileColabId },
    });

    // Idempotente — quitar algo que ya no está no falla
    if (!favorite) return { message: 'Eliminado de favoritos' };

    await this.favoriteRepository.remove(favorite);

    return { message: 'Eliminado de favoritos' };
  }
}
