import '../models/bar_datum.dart';
import '../models/statistics_period.dart';
import '../models/monthly_goal.dart';
import '../models/services_rate.dart';
import '../models/statistics_data.dart';
import 'statistics_repository.dart';

class MockStatisticsRepository implements StatisticsRepository {
  MockStatisticsRepository({
    DateTime Function()? now,
    this._empty = false,
    this._delay = const Duration(milliseconds: 400),
  }) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final bool _empty;
  final Duration _delay;
  MonthlyGoal? _goal;

  @override
  Future<StatisticsData> getStatistics(StatisticsPeriod period) async {
    await Future<void>.delayed(_delay);
    if (_empty) return StatisticsData.empty(period, now: _now());

    final now = _now();
    final goal = _goal != null && _goal!.isCurrent(now) ? _goal : null;

    return StatisticsData(
      period: period,
      bars: _barsFor(period),
      rate: const ServicesRate(requested: 3, offered: 42),
      averageRating: 4.7,
      totalServices: 42,
      monthlyOffered: 28,
      monthlyGoal: goal,
    );
  }

  @override
  Future<void> saveMonthlyGoal(int amount) async {
    await Future<void>.delayed(_delay);
    final now = _now();
    _goal = MonthlyGoal(amount: amount, month: now.month, year: now.year);
  }

  List<BarDatum> _barsFor(StatisticsPeriod period) {
    final values = switch (period) {
      StatisticsPeriod.days => const <double>[12, 18, 9, 24, 15, 6, 3],
      StatisticsPeriod.months => const <double>[
          22, 18, 30, 26, 35, 28, 40, 33, 45, 38, 50, 42,
        ],
      StatisticsPeriod.years => const <double>[60, 95, 120, 130],
    };

    final baseYear = _now().year - values.length + 1;
    return List<BarDatum>.generate(
      values.length,
      (index) => BarDatum(key: baseYear + index, value: values[index]),
    );
  }
}
