import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { UserFollows } from './entities/user-follows.entity';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,

    @InjectRepository(UserFollows)
    private userFollowsRepository: Repository<UserFollows>,
  ) {}

  // Mi perfil completo (privado)
  async getMyProfile(userId: string) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
      relations: [
        'profileColab',
        'profileColab.occupations',
      ],
    });

    if (!user) throw new NotFoundException('Usuario no encontrado');
    return user;
  }

  // Perfil público de otro usuario
  async getPublicProfile(targetId: string, requesterId: string) {
    const user = await this.userRepository.findOne({
      where: { id: targetId },
      relations: [
        'profileColab',
        'profileColab.occupations',
        'profileColab.posts',
      ],
    });

    if (!user) throw new NotFoundException('Usuario no encontrado');

    // Si soy yo mismo → devuelvo todo
    if (targetId === requesterId) return user;

    // Si es demandante → solo datos básicos
    if (!user.profileColab) {
      return {
        id: user.id,
        name: user.name,
        lastName: user.lastName,
        imageProfile: user.imageProfile,
        registrationDate: user.createdAt,
      };
    }

    // Si es colaborador → perfil completo público
    return user;
  }

  // Actualizar mi perfil
  async updateProfile(userId: string, updateProfileDto: UpdateProfileDto) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) throw new NotFoundException('Usuario no encontrado');

    Object.assign(user, updateProfileDto);
    return this.userRepository.save(user);
  }

  // Desactivar mi cuenta
  async deactivateAccount(userId: string) {
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });

    if (!user) throw new NotFoundException('Usuario no encontrado');

    user.status = 'inactive';
    return this.userRepository.save(user);
  }

  // Seguir a un usuario
  async follow(followerId: string, followingId: string) {
    if (followerId === followingId) {
      throw new ForbiddenException('No puedes seguirte a ti mismo');
    }

    const following = await this.userRepository.findOne({
      where: { id: followingId },
      relations: ['profileColab'],
    });

    if (!following) throw new NotFoundException('Usuario no encontrado');

    // Solo se puede seguir a colaboradores
    if (!following.profileColab) {
      throw new ForbiddenException('Solo puedes seguir a colaboradores');
    }

    const existingFollow = await this.userFollowsRepository.findOne({
      where: { followerId, followingId },
    });

    if (existingFollow) {
      throw new ForbiddenException('Ya sigues a este usuario');
    }

    const follow = this.userFollowsRepository.create({
      followerId,
      followingId,
    });

    return this.userFollowsRepository.save(follow);
  }

  // Dejar de seguir
  async unfollow(followerId: string, followingId: string) {
    const follow = await this.userFollowsRepository.findOne({
      where: { followerId, followingId },
    });

    if (!follow) {
      throw new NotFoundException('No sigues a este usuario');
    }

    return this.userFollowsRepository.remove(follow);
  }

  // Seguidores de un usuario
  async getFollowers(userId: string) {
    return this.userFollowsRepository.find({
      where: { followingId: userId },
      relations: ['follower'],
    });
  }

  // A quiénes sigue un usuario
  async getFollowing(userId: string) {
    return this.userFollowsRepository.find({
      where: { followerId: userId },
      relations: ['following'],
    });
  }
}