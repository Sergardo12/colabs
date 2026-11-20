import { Repository } from 'typeorm';
import { ServiceRequestService } from './service-request.service';
import { ServiceRequest } from './entities/service-request.entity';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { User } from '../users/entities/user.entity';
import { Occupation } from '../occupation/entities/occupation.entity';
import { Conversation } from '../conversation/entities/conversation.entity';
import { Message } from '../message/entities/message.entity';
import { Proposal } from '../proposal/entities/proposal.entity';
import { NotificationService } from '../notification/notification.service';
import { RedisService } from '../../common/services/redis.service';
import { CollabsGateway } from '../gateway/colabs.gateway';

interface QbMock {
  leftJoinAndSelect: jest.Mock<QbMock, []>;
  where: jest.Mock<QbMock, []>;
  andWhere: jest.Mock<QbMock, [string, unknown?]>;
  orderBy: jest.Mock<QbMock, []>;
  getMany: jest.Mock<Promise<ServiceRequest[]>, []>;
}

interface ServiceRequestRepoMock {
  createQueryBuilder: jest.Mock<QbMock, [string]>;
}

describe('ServiceRequestService.findCancelledWithColab', () => {
  let qb: QbMock;
  let andWhereCalls: Array<{ condition: string; params?: unknown }>;
  let allServices: ServiceRequest[];
  let reportedIds: Set<string>;
  let serviceRequestRepository: ServiceRequestRepoMock;
  let service: ServiceRequestService;

  beforeEach(() => {
    andWhereCalls = [];
    allServices = [
      {
        id: 'sr-unreported',
        description: 'sin reporte',
        profileColabId: 'pc-1',
        occupationId: 'occ-1',
        occupation: { id: 'occ-1', name: 'Electricista', image: null },
        proposals: [],
      },
      {
        id: 'sr-reported',
        description: 'reportado',
        profileColabId: 'pc-2',
        occupationId: 'occ-1',
        occupation: { id: 'occ-1', name: 'Electricista', image: null },
        proposals: [],
      },
    ] as unknown as ServiceRequest[];
    reportedIds = new Set(['sr-reported']);

    qb = {} as QbMock;
    qb.leftJoinAndSelect = jest.fn<QbMock, []>(() => qb);
    qb.where = jest.fn<QbMock, []>(() => qb);
    qb.andWhere = jest.fn<QbMock, [string, unknown?]>((condition, params) => {
      andWhereCalls.push({ condition, params });
      return qb;
    });
    qb.orderBy = jest.fn<QbMock, []>(() => qb);
    qb.getMany = jest.fn<Promise<ServiceRequest[]>, []>(() => {
      const hasExclusion = andWhereCalls.some(
        ({ condition }) =>
          condition.includes('NOT EXISTS') &&
          condition.includes('FROM reports') &&
          condition.includes('r.service_request_id = sr.id'),
      );
      return Promise.resolve(
        hasExclusion
          ? allServices.filter((sr) => !reportedIds.has(sr.id))
          : allServices,
      );
    });

    serviceRequestRepository = {
      createQueryBuilder: jest.fn<QbMock, [string]>(() => qb),
    };

    service = new ServiceRequestService(
      serviceRequestRepository as unknown as Repository<ServiceRequest>,
      null as unknown as Repository<ProfileColab>,
      null as unknown as Repository<User>,
      null as unknown as Repository<Occupation>,
      null as unknown as Repository<Conversation>,
      null as unknown as Repository<Message>,
      null as unknown as Repository<Proposal>,
      null as unknown as NotificationService,
      null as unknown as RedisService,
      null as unknown as CollabsGateway,
    );
  });

  const hasNotExists = () =>
    andWhereCalls.some(
      ({ condition }) =>
        condition.includes('NOT EXISTS') &&
        condition.includes('FROM reports') &&
        condition.includes('r.service_request_id = sr.id'),
    );

  it('excluye los servicios que ya tienen reporte sin usar search', async () => {
    const result = await service.findCancelledWithColab('user-1');

    expect(hasNotExists()).toBe(true);
    expect(result.map((r) => r.id)).toEqual(['sr-unreported']);
  });

  it('excluye los servicios que ya tienen reporte usando search', async () => {
    const result = await service.findCancelledWithColab('user-1', 'electric');

    expect(hasNotExists()).toBe(true);
    expect(
      andWhereCalls.some(({ condition }) => condition.includes('ILIKE')),
    ).toBe(true);
    expect(result.map((r) => r.id)).toEqual(['sr-unreported']);
  });

  it('sigue devolviendo los servicios que no tienen reporte', async () => {
    const result = await service.findCancelledWithColab('user-1');

    expect(result).toEqual([
      expect.objectContaining({
        id: 'sr-unreported',
        profileColabId: 'pc-1',
      }),
    ]);
  });
});
