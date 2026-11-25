import '../models/bar_datum.dart';
import '../models/monthly_goal.dart';
import '../models/services_offered_response.dart';
import '../models/services_rate.dart';
import '../models/statistics_period.dart';
import 'statistics_repository.dart';

class MockStatisticsRepository implements StatisticsRepository {
  MockStatisticsRepository({
    DateTime Function()? now,
    this._accountCreatedYear,
    this._empty = false,
    this._delay = const Duration(milliseconds: 400),
  }) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final int? _accountCreatedYear;
  final bool _empty;
  final Duration _delay;
  MonthlyGoal? _goal;
  final int _offeredInMonth = 30;

  @override
  Future<ServicesOfferedResponse> getServicesOffered(
    StatisticsPeriod period,
  ) async {
    await Future<void>.delayed(_delay);
    return ServicesOfferedResponse(
      period: period,
      accountCreatedYear:
          _accountCreatedYear ?? _now().year - 3,
      bars: _empty
          ? List<BarDatum>.generate(
              period == StatisticsPeriod.days
                  ? 7
                  : period == StatisticsPeriod.months
                      ? 12
                      : 1,
              (index) => BarDatum(key: index + 1, value: 0),
            )
          : _barsFor(period),
    );
  }

  @override
  Future<int> getServicesTotal(StatisticsPeriod period) async {
    await Future<void>.delayed(_delay);
    return _empty ? 0 : 150;
  }

  @override
  Future<ServicesRate> getServicesRate() async {
    await Future<void>.delayed(_delay);
    return _empty ? ServicesRate.empty : const ServicesRate(requested: 25, offered: 75);
  }

  @override
  Future<double?> getAverageRating() async {
    await Future<void>.delayed(_delay);
    return _empty ? null : 4.7;
  }

  @override
  Future<MonthlyGoal?> getMonthlyGoal() async {
    await Future<void>.delayed(_delay);
    final now = _now();
    if (_goal == null || !_goal!.isCurrent(now)) return null;
    return _goal!.copyWith(offered: _offeredInMonth);
  }

  @override
  Future<MonthlyGoal> saveMonthlyGoal(int amount) async {
    await Future<void>.delayed(_delay);
    final now = _now();
    _goal = MonthlyGoal(
      amount: amount,
      month: now.month,
      year: now.year,
      offered: _offeredInMonth,
    );
    return _goal!;
  }

  List<BarDatum> _barsFor(StatisticsPeriod period) {
    return switch (period) {
      StatisticsPeriod.days => _dayBars,
      StatisticsPeriod.months => _monthBars,
      StatisticsPeriod.years => _yearBars(),
    };
  }

  List<BarDatum> get _dayBars {
    const values = <double>[15, 24, 33, 44, 30, 20, 10];
    return List<BarDatum>.generate(
      values.length,
      (index) => BarDatum(key: index + 1, value: values[index]),
    );
  }

  List<BarDatum> get _monthBars {
    const values = <double>[
      22, 18, 30, 26, 35, 28, 40, 33, 45, 38, 50, 42,
    ];
    return List<BarDatum>.generate(
      values.length,
      (index) => BarDatum(key: index + 1, value: values[index]),
    );
  }

  List<BarDatum> _yearBars() {
    final currentYear = _now().year;
    final startYear = _accountCreatedYear ?? currentYear - 3;
    final count = currentYear - startYear + 1;
    const values = <double>[60, 95, 120, 130, 140];

    return List<BarDatum>.generate(
      count,
      (index) => BarDatum(
        key: startYear + index,
        value: values[index % values.length],
      ),
    );
  }
}
