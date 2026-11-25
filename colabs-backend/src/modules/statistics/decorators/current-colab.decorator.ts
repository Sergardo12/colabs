import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { ProfileColab } from '../../profile-colab/entities/profile-colab.entity';
import { StatisticsRequest } from '../guards/colab.guard';

export const CurrentColab = createParamDecorator(
  (_data: unknown, context: ExecutionContext): ProfileColab => {
    const request = context.switchToHttp().getRequest<StatisticsRequest>();
    return request.profileColab;
  },
);
