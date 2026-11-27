import 'package:equatable/equatable.dart';
import 'bar_datum.dart';
import 'monthly_goal.dart';
import 'services_rate.dart';
import 'statistics_period.dart';

class StatisticsData extends Equatable {
  final StatisticsPeriod period;
  final List<BarDatum> bars;
  final ServicesRate rate;
  final double? averageRating;
  final int totalServices;
  final int monthlyOffered;
  final MonthlyGoal? monthlyGoal;
  final int accountCreatedYear;

  const StatisticsData({
    required this.period,
    required this.bars,
    required this.rate,
    required this.averageRating,
    required this.totalServices,
    required this.monthlyOffered,
    required this.accountCreatedYear,
    this.monthlyGoal,
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    final goalJson = json['monthlyGoal'] as Map<String, dynamic>?;
    final goal = goalJson == null ? null : MonthlyGoal.fromJson(goalJson);
    final now = DateTime.now();
    return StatisticsData(
      period: statisticsPeriodFromValue(json['period'] as String? ?? 'days'),
      bars: (json['bars'] as List<dynamic>? ?? const [])
          .map((item) => BarDatum.fromJson(item as Map<String, dynamic>))
          .toList(),
      rate: json['rate'] == null
          ? ServicesRate.empty
          : ServicesRate.fromJson(json['rate'] as Map<String, dynamic>),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalServices: (json['totalServices'] as num?)?.toInt() ?? 0,
      monthlyOffered: goal?.offered ??
          (json['monthlyOffered'] as num?)?.toInt() ??
          0,
      monthlyGoal: goal,
      accountCreatedYear:
          (json['accountCreatedYear'] as num?)?.toInt() ?? now.year,
    );
  }

  factory StatisticsData.empty(StatisticsPeriod period, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final year = current.year;
    final keys = switch (period) {
      StatisticsPeriod.days => List<int>.generate(7, (i) => i + 1),
      StatisticsPeriod.months => List<int>.generate(12, (i) => i + 1),
      StatisticsPeriod.years => <int>[year],
    };
    return StatisticsData(
      period: period,
      bars: keys.map((key) => BarDatum(key: key, value: 0)).toList(),
      rate: ServicesRate.empty,
      averageRating: null,
      totalServices: 0,
      monthlyOffered: 0,
      accountCreatedYear: year,
    );
  }

  int get _maxBarValue => bars.fold<int>(
        0,
        (max, bar) => bar.value > max ? bar.value.ceil() : max,
      );

  int get yAxisInterval {
    final max = _maxBarValue;
    if (max <= 50) return 5;
    var interval = 10;
    while (_ceilDiv(max, interval) > 10) {
      interval += 5;
    }
    return interval;
  }

  int get yAxisMax {
    final max = _maxBarValue;
    if (max <= 50) return 50;
    return _ceilDiv(max, yAxisInterval) * yAxisInterval;
  }

  bool get isEmpty =>
      bars.every((bar) => bar.value <= 0) &&
      rate.requested <= 0 &&
      rate.offered <= 0 &&
      totalServices <= 0;

  int get goalPercent {
    final goal = monthlyGoal;
    if (goal == null || goal.amount <= 0) return 0;
    return (monthlyOffered / goal.amount * 100).round().clamp(0, 100);
  }

  bool get isGoalReached =>
      monthlyGoal != null && monthlyOffered >= monthlyGoal!.amount;

  StatisticsData copyWith({
    StatisticsPeriod? period,
    List<BarDatum>? bars,
    ServicesRate? rate,
    double? averageRating,
    bool clearAverageRating = false,
    int? totalServices,
    int? monthlyOffered,
    MonthlyGoal? monthlyGoal,
    bool clearGoal = false,
    int? accountCreatedYear,
  }) {
    return StatisticsData(
      period: period ?? this.period,
      bars: bars ?? this.bars,
      rate: rate ?? this.rate,
      averageRating:
          clearAverageRating ? null : (averageRating ?? this.averageRating),
      totalServices: totalServices ?? this.totalServices,
      monthlyOffered: monthlyOffered ?? this.monthlyOffered,
      monthlyGoal: clearGoal ? null : (monthlyGoal ?? this.monthlyGoal),
      accountCreatedYear: accountCreatedYear ?? this.accountCreatedYear,
    );
  }

  static int _ceilDiv(int value, int divisor) => (value / divisor).ceil();

  @override
  List<Object?> get props => [
        period,
        bars,
        rate,
        averageRating,
        totalServices,
        monthlyOffered,
        monthlyGoal,
        accountCreatedYear,
      ];
}
