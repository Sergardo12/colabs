import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { ProposalStatus } from '../../common/enums/proposal-status.enum';
import { StatisticsPeriod } from './enums/statistics-period.enum';
import { StatisticsService } from './statistics.service';

class QueryBuilderMock {
  select = jest.fn().mockReturnThis();
  distinct = jest.fn().mockReturnThis();
  innerJoin = jest.fn().mockReturnThis();
  leftJoin = jest.fn().mockReturnThis();
  where = jest.fn().mockReturnThis();
  andWhere = jest.fn().mockReturnThis();
  setParameters = jest.fn().mockReturnThis();
  getMany = jest.fn();
  getOne = jest.fn();
}

const profile = {
  id: 'profile-1',
  userId: 'user-1',
} as ProfileColab;

const utc = (year: number, month: number, day: number) =>
  new Date(Date.UTC(year, month - 1, day, 12));

describe('StatisticsService', () => {
  let monthlyGoalRepository: any;
  let userRepository: any;
  let serviceRequestRepository: any;
  let commentRequestRepository: any;
  let service: StatisticsService;
  let srQuery: QueryBuilderMock;
  let userQuery: QueryBuilderMock;
  let commentQuery: QueryBuilderMock;

  beforeEach(() => {
    monthlyGoalRepository = {
      findOne: jest.fn(),
      create: jest.fn((value) => value),
      save: jest.fn(async (value) => value),
    };
    userRepository = { createQueryBuilder: jest.fn() };
    serviceRequestRepository = { createQueryBuilder: jest.fn() };
    commentRequestRepository = { createQueryBuilder: jest.fn() };

    srQuery = new QueryBuilderMock();
    userQuery = new QueryBuilderMock();
    commentQuery = new QueryBuilderMock();
    userRepository.createQueryBuilder.mockReturnValue(userQuery);
    serviceRequestRepository.createQueryBuilder.mockReturnValue(srQuery);
    commentRequestRepository.createQueryBuilder.mockReturnValue(commentQuery);

    service = new StatisticsService(
      monthlyGoalRepository,
      userRepository,
      serviceRequestRepository,
      commentRequestRepository,
    );
    jest.spyOn(service as any, 'now').mockReturnValue(utc(2026, 11, 22));
    userQuery.getOne.mockResolvedValue({ registrationDate: utc(2024, 5, 10) });
  });

  it('agrupa las barras de días por weekday UTC y rellena huecos', async () => {
    srQuery.getMany.mockResolvedValue([
      { id: 'a', completionDate: utc(2026, 11, 16) },
      { id: 'b', completionDate: utc(2026, 11, 22) },
      { id: 'c', completionDate: utc(2026, 11, 22) },
    ]);

    const result = await service.getServicesOffered(profile, StatisticsPeriod.DAYS);

    expect(result.accountCreatedYear).toBe(2024);
    expect(result.bars).toEqual([
      { key: 1, value: 1 },
      { key: 2, value: 0 },
      { key: 3, value: 0 },
      { key: 4, value: 0 },
      { key: 5, value: 0 },
      { key: 6, value: 0 },
      { key: 7, value: 2 },
    ]);
    expect(userQuery.getOne).toHaveBeenCalled();
  });

  it('el total de meses usa el mes actual, no la suma de barras', async () => {
    srQuery.getMany.mockResolvedValue([
      { id: 'a', completionDate: utc(2026, 11, 2) },
      { id: 'b', completionDate: utc(2026, 11, 20) },
    ]);
    jest.spyOn(service as any, 'now').mockReturnValue(utc(2026, 11, 24));

    await expect(
      service.getServicesTotal(profile, StatisticsPeriod.MONTHS),
    ).resolves.toEqual({ period: StatisticsPeriod.MONTHS, total: 2 });

    const whereCalls = srQuery.andWhere.mock.calls.map(([sql]) => sql);
    expect(whereCalls).toContain('sr.completionDate >= :from');
    expect(whereCalls).toContain('sr.completionDate < :to');
  });

  it('cuenta solicitados no cancelados y ofrecidos completados', async () => {
    srQuery.getMany
      .mockResolvedValueOnce([{ id: 'r1' }, { id: 'r1' }, { id: 'r2' }])
      .mockResolvedValueOnce([{ id: 'o1' }, { id: 'o1' }]);

    await expect(service.getServicesRate(profile)).resolves.toEqual({
      requested: 2,
      offered: 1,
    });

    expect(srQuery.where).toHaveBeenCalledWith('sr.userId = :userId', {
      userId: 'user-1',
    });
    expect(srQuery.andWhere).toHaveBeenCalledWith('sr.status != :cancelled', {
      cancelled: 'cancelled',
    });
  });

  it('excluye Flujo B usando solo propiedades de entidad en el QueryBuilder', async () => {
    srQuery.getMany.mockResolvedValue([]);
    await service.getServicesTotal(profile, StatisticsPeriod.DAYS);

    expect(srQuery.leftJoin).toHaveBeenCalledWith(
      'sr.proposals',
      'acceptedProposal',
      'acceptedProposal.status = :acceptedStatus',
    );
    const conditions = srQuery.andWhere.mock.calls.map(([sql]) => sql).join(' ');
    expect(conditions).toContain('sr.profileColabId = :profileColabId');
    expect(conditions).toContain(
      'acceptedProposal.profileColabId = :profileColabId',
    );
    expect(srQuery.setParameters).toHaveBeenCalledWith(
      expect.objectContaining({ acceptedStatus: ProposalStatus.ACCEPTED }),
    );
  });

  it('devuelve null de promedio sin calificaciones y redondea cuando hay', async () => {
    commentQuery.getMany.mockResolvedValueOnce([]);
    await expect(service.getAverageRating(profile)).resolves.toEqual({
      averageRating: null,
    });

    const conditions = commentQuery.andWhere.mock.calls
      .map(([sql]) => sql)
      .join(' ');
    expect(conditions).toContain('sr.completionDate IS NOT NULL');

    commentQuery.getMany.mockResolvedValueOnce([
      { id: 'c1', rating: 5 },
      { id: 'c1', rating: 5 },
      { id: 'c2', rating: 4 },
    ]);
    await expect(service.getAverageRating(profile)).resolves.toEqual({
      averageRating: 4.5,
    });
  });

  it('guarda la meta del mes y devuelve offered sin recargar otros datos', async () => {
    monthlyGoalRepository.findOne.mockResolvedValue(null);
    srQuery.getMany.mockResolvedValue([
      { id: 'o1', completionDate: utc(2026, 11, 2) },
    ]);

    await expect(service.saveMonthlyGoal(profile, 25)).resolves.toEqual({
      amount: 25,
      offered: 1,
      month: 11,
      year: 2026,
    });
    expect(monthlyGoalRepository.create).toHaveBeenCalledWith({
      profileColabId: 'profile-1',
      month: 11,
      year: 2026,
      amount: 25,
    });
  });

  it('actualiza una meta existente sin duplicarla', async () => {
    monthlyGoalRepository.findOne.mockResolvedValue({
      id: 'goal-1',
      profileColabId: 'profile-1',
      month: 11,
      year: 2026,
      amount: 10,
    });
    srQuery.getMany.mockResolvedValue([]);

    await service.saveMonthlyGoal(profile, 30);

    expect(monthlyGoalRepository.create).not.toHaveBeenCalled();
    expect(monthlyGoalRepository.save).toHaveBeenCalledWith(
      expect.objectContaining({ id: 'goal-1', amount: 30 }),
    );
  });
});
