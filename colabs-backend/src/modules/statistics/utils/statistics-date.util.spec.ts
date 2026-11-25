import { StatisticsPeriod } from '../enums/statistics-period.enum';
import {
  barKeyForDate,
  buildBarKeys,
  getBarsRange,
  getTotalRange,
  startOfUtcWeek,
} from './statistics-date.util';

const utc = (year: number, month: number, day: number) =>
  new Date(Date.UTC(year, month - 1, day, 12));

describe('statistics date utils', () => {
  it('computa la semana UTC desde lunes hasta domingo', () => {
    const sunday = utc(2026, 11, 22);
    expect(startOfUtcWeek(sunday).toISOString()).toBe('2026-11-16T00:00:00.000Z');

    const range = getBarsRange(StatisticsPeriod.DAYS, sunday, 2026);
    expect(range.from.toISOString()).toBe('2026-11-16T00:00:00.000Z');
    expect(range.to.toISOString()).toBe('2026-11-23T00:00:00.000Z');
  });

  it('el lunes inicia una semana nueva con rango semiabierto', () => {
    const monday = utc(2026, 11, 23);
    const range = getBarsRange(StatisticsPeriod.DAYS, monday, 2026);
    expect(range.from.toISOString()).toBe('2026-11-23T00:00:00.000Z');
    expect(range.to.toISOString()).toBe('2026-11-30T00:00:00.000Z');
    expect(barKeyForDate(StatisticsPeriod.DAYS, monday)).toBe(1);
    expect(barKeyForDate(StatisticsPeriod.DAYS, utc(2026, 11, 22))).toBe(7);
  });

  it('usa rangos de total distintos a los de barras', () => {
    const now = utc(2026, 11, 24);
    expect(getTotalRange(StatisticsPeriod.DAYS, now)).toEqual({
      from: new Date('2026-11-24T00:00:00.000Z'),
      to: new Date('2026-11-25T00:00:00.000Z'),
    });
    expect(getBarsRange(StatisticsPeriod.MONTHS, now, 2020)).toEqual({
      from: new Date('2026-01-01T00:00:00.000Z'),
      to: new Date('2027-01-01T00:00:00.000Z'),
    });
  });

  it('respeta primer y último día de mes y cambio de año', () => {
    expect(getTotalRange(StatisticsPeriod.MONTHS, utc(2026, 1, 31))).toEqual({
      from: new Date('2026-01-01T00:00:00.000Z'),
      to: new Date('2026-02-01T00:00:00.000Z'),
    });
    expect(getTotalRange(StatisticsPeriod.YEARS, utc(2026, 12, 31))).toEqual({
      from: new Date('2026-01-01T00:00:00.000Z'),
      to: new Date('2027-01-01T00:00:00.000Z'),
    });
  });

  it('genera una sola barra cuando la cuenta se creó este año', () => {
    expect(buildBarKeys(StatisticsPeriod.YEARS, utc(2026, 11, 24), 2026)).toEqual([
      2026,
    ]);
    expect(getBarsRange(StatisticsPeriod.YEARS, utc(2026, 11, 24), 2026)).toEqual({
      from: new Date('2026-01-01T00:00:00.000Z'),
      to: new Date('2027-01-01T00:00:00.000Z'),
    });
  });
});
