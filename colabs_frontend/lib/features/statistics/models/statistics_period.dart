enum StatisticsPeriod { days, months, years }

extension StatisticsPeriodX on StatisticsPeriod {
  String get key => switch (this) {
        StatisticsPeriod.days => 'days',
        StatisticsPeriod.months => 'months',
        StatisticsPeriod.years => 'years',
      };
}

StatisticsPeriod statisticsPeriodFromValue(String value) => switch (value) {
      'days' => StatisticsPeriod.days,
      'months' => StatisticsPeriod.months,
      'years' => StatisticsPeriod.years,
      _ => StatisticsPeriod.days,
    };
