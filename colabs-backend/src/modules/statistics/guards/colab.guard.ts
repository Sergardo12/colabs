import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProfileColab } from '../../profile-colab/entities/profile-colab.entity';
import { JwtPayload } from '../../../common/interfaces/jwt-payload.interface';

export interface StatisticsRequest extends Request {
  user: JwtPayload;
  profileColab: ProfileColab;
}

@Injectable()
export class ColabGuard implements CanActivate {
  constructor(
    @InjectRepository(ProfileColab)
    private readonly profileColabRepository: Repository<ProfileColab>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<StatisticsRequest>();
    const profileColab = await this.profileColabRepository.findOne({
      where: { userId: request.user.id },
    });

    if (!profileColab) {
      throw new ForbiddenException('No tienes perfil de colaborador');
    }

    request.profileColab = profileColab;
    return true;
  }
}
