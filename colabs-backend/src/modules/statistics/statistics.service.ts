import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, SelectQueryBuilder } from 'typeorm';
import { ProfileColab } from '../profile-colab/entities/profile-colab.entity';
import { User } from '../users/entities/user.entity';
import { ServiceRequest } from '../service-request/entities/service-request.entity';
import { CommentRequestService } from '../comment-request/comment-request.service';
import { ProposalStatus } from '../../common/enums/proposal-status.enum';
import { ServiceRequestStatus } from '../../common/enums/service-request-status.enum';
import { MonthlyGoal } from './entities/monthly-goal.entity';
import { StatisticsPeriod } from './enums/statistics-period.enum';
import {
  DateRange,
  barKeyForDate,
  buildBarKeys,
  getBarsRange,
  getTotalRange,
} from './utils/statistics-date.util';

export interface BarResult {
  key: number;
  value: number;
}

export interface ServicesOfferedResult {
  period: StatisticsPeriod;
  accountCreatedYear: number;
  bars: BarResult[];
}

export interface ServicesTotalResult {
  period: StatisticsPeriod;
  total: number;
}

export interface ServicesRateResult {
  requested: number;
  offered: number;
}

export interface AverageRatingResult {
  averageRating: number | null;
}

export interface MonthlyGoalResult {
  amount: number;
  offered: number;
  month: number;
  year: number;
}

@Injectable()
export class StatisticsService {
  constructor(
    @InjectRepository(MonthlyGoal)
    private readonly monthlyGoalRepository: Repository<MonthlyGoal>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(ServiceRequest)
    private readonly serviceRequestRepository: Repository<ServiceRequest>,
    private readonly commentRequestService: CommentRequestService,
  ) {}

  async getServicesOffered(
    profileColab: ProfileColab,
    period: StatisticsPeriod,
  ): Promise<ServicesOfferedResult> {
    const now = this.now();
    const accountCreatedYear = await this.getAccountCreatedYear(
      profileColab.userId,
      now,
    );
    const range = getBarsRange(period, now, accountCreatedYear);
    const requests = await this.findCompleted(profileColab.id, range);

    const counts = new Map<number, number>();
    for (const request of requests) {
      if (!request.completionDate) continue;
      const key = barKeyForDate(period, request.completionDate);
      counts.set(key, (counts.get(key) ?? 0) + 1);
    }

    return {
      period,
      accountCreatedYear,
      bars: buildBarKeys(period, now, accountCreatedYear).map((key) => ({
        key,
        value: counts.get(key) ?? 0,
      })),
    };
  }

  async getServicesTotal(
    profileColab: ProfileColab,
    period: StatisticsPeriod,
  ): Promise<ServicesTotalResult> {
    const range = getTotalRange(period, this.now());
    const requests = await this.findCompleted(profileColab.id, range);
    return { period, total: requests.length };
  }

  async getServicesRate(
    profileColab: ProfileColab,
  ): Promise<ServicesRateResult> {
    const requestedRows = await this.serviceRequestRepository
      .createQueryBuilder('sr')
      .select(['sr.id'])
      .where('sr.userId = :userId', { userId: profileColab.userId })
      .andWhere('sr.status != :cancelled', {
        cancelled: ServiceRequestStatus.CANCELLED,
      })
      .getMany();

    const offeredRows = await this.findCompleted(profileColab.id);

    return {
      requested: this.uniqueById(requestedRows).length,
      offered: offeredRows.length,
    };
  }

  async getAverageRating(
    profileColab: ProfileColab,

  ): Promise<AverageRatingResult> {
    const { averageRating, totalReviews } =
      await this.commentRequestService.findByProfileColab(profileColab.id);

    return {
      averageRating: totalReviews === 0 ? null : averageRating,
    };
  }

  async getMonthlyGoal(
    profileColab: ProfileColab,
  ): Promise<MonthlyGoalResult | null> {
    const now = this.now();
    const month = now.getUTCMonth() + 1;
    const year = now.getUTCFullYear();

    const goal = await this.monthlyGoalRepository.findOne({
      where: {
        profileColabId: profileColab.id,
        month,
        year,
      },
    });
    if (!goal) return null;

    const offered = await this.countCompleted(
      profileColab.id,
      getTotalRange(StatisticsPeriod.MONTHS, now),
    );

    return {
      amount: goal.amount,
      offered,
      month: goal.month,
      year: goal.year,
    };
  }

  async saveMonthlyGoal(
    profileColab: ProfileColab,
    amount: number,
  ): Promise<MonthlyGoalResult> {
    const now = this.now();
    const month = now.getUTCMonth() + 1;
    const year = now.getUTCFullYear();

    let goal = await this.monthlyGoalRepository.findOne({
      where: {
        profileColabId: profileColab.id,
        month,
        year,
      },
    });

    if (!goal) {
      goal = this.monthlyGoalRepository.create({
        profileColabId: profileColab.id,
        month,
        year,
        amount,
      });
    } else {
      goal.amount = amount;
    }

    const saved = await this.monthlyGoalRepository.save(goal);
    const offered = await this.countCompleted(
      profileColab.id,
      getTotalRange(StatisticsPeriod.MONTHS, now),
    );

    return {
      amount: saved.amount,
      offered,
      month: saved.month,
      year: saved.year,
    };
  }

  private async getAccountCreatedYear(userId: string, now: Date): Promise<number> {
    const user = await this.userRepository
      .createQueryBuilder('user')
      .select(['user.registrationDate'])
      .where('user.id = :userId', { userId })
      .getOne();

    const registrationDate = user?.registrationDate;
    if (
      registrationDate instanceof Date &&
      !Number.isNaN(registrationDate.getTime())
    ) {
      return registrationDate.getUTCFullYear();
    }
    return now.getUTCFullYear();
  }

  private async findCompleted(
    profileColabId: string,
    range?: DateRange,
  ): Promise<ServiceRequest[]> {
    const query = this.completedQuery(profileColabId);
    if (range) {
      query
        .andWhere('sr.completionDate >= :from', { from: range.from })
        .andWhere('sr.completionDate < :to', { to: range.to });
    }
    return this.uniqueById(await query.getMany());
  }

  private async countCompleted(
    profileColabId: string,
    range?: DateRange,
  ): Promise<number> {
    return (await this.findCompleted(profileColabId, range)).length;
  }

  private completedQuery(profileColabId: string): SelectQueryBuilder<ServiceRequest> {
    return this.serviceRequestRepository
      .createQueryBuilder('sr')
      .select(['sr.id', 'sr.completionDate'])
      .where('sr.status = :completed', {
        completed: ServiceRequestStatus.COMPLETED,
      })
      .andWhere('sr.completionDate IS NOT NULL')
      .leftJoin(
        'sr.proposals',
        'acceptedProposal',
        'acceptedProposal.status = :acceptedStatus',
      )
      .andWhere(this.winnerCondition())
      .setParameters({
        profileColabId,
        acceptedStatus: ProposalStatus.ACCEPTED,
      });
  }

  private winnerCondition(): string {
    // TODO(statistics): incluir Flujo B cuando se defina la atribución del colaborador.
    return `(sr.profileColabId = :profileColabId
      OR (sr.profileColabId IS NULL
        AND acceptedProposal.profileColabId = :profileColabId))`;
  }

  private uniqueById<T extends { id: string }>(rows: T[]): T[] {
    return Array.from(new Map(rows.map((row) => [row.id, row])).values());
  }

  private now(): Date {
    return new Date();
  }
}
