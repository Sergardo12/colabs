import 'package:flutter_test/flutter_test.dart';
import 'package:colabs_frontend/features/statistics/models/bar_datum.dart';
import 'package:colabs_frontend/features/statistics/models/monthly_goal.dart';
import 'package:colabs_frontend/features/statistics/models/services_rate.dart';
import 'package:colabs_frontend/features/statistics/models/statistics_data.dart';
import 'package:colabs_frontend/features/statistics/models/statistics_period.dart';

StatisticsData _dataWithMax(double max) {
  return StatisticsData(
    period: StatisticsPeriod.months,
    bars: [BarDatum(key: 1, value: max)],
    rate: const ServicesRate(requested: 1, offered: 1),
    averageRating: 4.5,
    totalServices: 1,
    monthlyOffered: 1,
  );
}

void main() {
  group('StatisticsData', () {
    test('yAxisMax usa 50 con escala de 5 en 5', () {
      expect(_dataWithMax(48).yAxisMax, 50);
      expect(_dataWithMax(48).yAxisInterval, 5);
    });

    test('yAxisMax crece en pasos múltiplos de 5', () {
      expect(_dataWithMax(95).yAxisMax, 100);
      expect(_dataWithMax(95).yAxisInterval, 10);
      expect(_dataWithMax(130).yAxisMax, 135);
      expect(_dataWithMax(130).yAxisInterval, 15);
      expect(_dataWithMax(190).yAxisMax, 200);
      expect(_dataWithMax(190).yAxisInterval, 20);
    });

    test('goalPercent calcula, limita y maneja metas inválidas', () {
      final goal = _dataWithMax(10).copyWith(
        monthlyOffered: 28,
        monthlyGoal: const MonthlyGoal(amount: 70, month: 1, year: 2026),
      );
      expect(goal.goalPercent, 40);

      expect(
        goal.copyWith(monthlyOffered: 100).goalPercent,
        100,
      );
      expect(_dataWithMax(10).goalPercent, 0);
      expect(
        goal.copyWith(
          monthlyGoal: const MonthlyGoal(amount: 0, month: 1, year: 2026),
        ).goalPercent,
        0,
      );
    });

    test('isEmpty distingue datos vacíos de datos con servicios', () {
      expect(
        StatisticsData.empty(StatisticsPeriod.days).isEmpty,
        isTrue,
      );
      expect(_dataWithMax(10).isEmpty, isFalse);
    });
  });
}
