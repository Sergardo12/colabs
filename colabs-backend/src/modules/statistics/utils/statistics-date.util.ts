import { StatisticsPeriod } from '../enums/statistics-period.enum';

export interface DateRange {
  from: Date;
  to: Date;
}

const DAY_MS = 24 * 60 * 60 * 1000;

export function startOfUtcDay(value: Date): Date {
  return new Date(
    Date.UTC(value.getUTCFullYear(), value.getUTCMonth(), value.getUTCDate()),
  );
}

export function addUtcDays(value: Date, days: number): Date {
  return new Date(value.getTime() + days * DAY_MS);
}

export function startOfUtcWeek(value: Date): Date {
  const day = startOfUtcDay(value);
  const mondayOffset = (day.getUTCDay() + 6) % 7;
  return addUtcDays(day, -mondayOffset);
}

export function startOfUtcMonth(value: Date): Date {
  return new Date(Date.UTC(value.getUTCFullYear(), value.getUTCMonth(), 1));
}

export function addUtcMonths(value: Date, months: number): Date {
  return new Date(
    Date.UTC(
      value.getUTCFullYear(),
      value.getUTCMonth() + months,
      value.getUTCDate(),
    ),
  );
}

export function startOfUtcYear(value: Date): Date {
  return new Date(Date.UTC(value.getUTCFullYear(), 0, 1));
}

export function addUtcYears(value: Date, years: number): Date {
  return new Date(
    Date.UTC(value.getUTCFullYear() + years, value.getUTCMonth(), value.getUTCDate()),
  );
}

export function getTotalRange(period: StatisticsPeriod, now: Date): DateRange {
  switch (period) {
    case StatisticsPeriod.DAYS: {
      const from = startOfUtcDay(now);
      return { from, to: addUtcDays(from, 1) };
    }
    case StatisticsPeriod.MONTHS: {
      const from = startOfUtcMonth(now);
      return { from, to: addUtcMonths(from, 1) };
    }
    case StatisticsPeriod.YEARS: {
      const from = startOfUtcYear(now);
      return { from, to: addUtcYears(from, 1) };
    }
  }
}

export function getBarsRange(
  period: StatisticsPeriod,
  now: Date,
  accountCreatedYear: number,
): DateRange {
  switch (period) {
    case StatisticsPeriod.DAYS: {
      const from = startOfUtcWeek(now);
      return { from, to: addUtcDays(from, 7) };
    }
    case StatisticsPeriod.MONTHS: {
      const from = startOfUtcYear(now);
      return { from, to: addUtcYears(from, 1) };
    }
    case StatisticsPeriod.YEARS: {
      const from = new Date(Date.UTC(accountCreatedYear, 0, 1));
      return { from, to: new Date(Date.UTC(now.getUTCFullYear() + 1, 0, 1)) };
    }
  }
}

export function buildBarKeys(
  period: StatisticsPeriod,
  now: Date,
  accountCreatedYear: number,
): number[] {
  switch (period) {
    case StatisticsPeriod.DAYS:
      return [1, 2, 3, 4, 5, 6, 7];
    case StatisticsPeriod.MONTHS:
      return Array.from({ length: 12 }, (_, index) => index + 1);
    case StatisticsPeriod.YEARS:
      return Array.from(
        { length: now.getUTCFullYear() - accountCreatedYear + 1 },
        (_, index) => accountCreatedYear + index,
      );
  }
}

export function barKeyForDate(period: StatisticsPeriod, value: Date): number {
  switch (period) {
    case StatisticsPeriod.DAYS:
      return ((value.getUTCDay() + 6) % 7) + 1;
    case StatisticsPeriod.MONTHS:
      return value.getUTCMonth() + 1;
    case StatisticsPeriod.YEARS:
      return value.getUTCFullYear();
  }
}
