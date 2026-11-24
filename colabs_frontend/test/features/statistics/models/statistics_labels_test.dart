import 'package:flutter_test/flutter_test.dart';
import 'package:colabs_frontend/features/statistics/models/statistics_labels.dart';
import 'package:colabs_frontend/features/statistics/models/statistics_period.dart';

void main() {
  group('StatisticsLabels', () {
    test('etiqueta los días de la semana en español', () {
      expect(StatisticsLabels.forBar(1, StatisticsPeriod.days), 'Lunes');
      expect(StatisticsLabels.forBar(4, StatisticsPeriod.days), 'Jueves');
      expect(StatisticsLabels.forBar(7, StatisticsPeriod.days), 'Domingo');
    });

    test('etiqueta los meses del año en español', () {
      expect(StatisticsLabels.forBar(1, StatisticsPeriod.months), 'Ene');
      expect(StatisticsLabels.forBar(8, StatisticsPeriod.months), 'Ago');
      expect(StatisticsLabels.forBar(12, StatisticsPeriod.months), 'Dic');
    });

    test('etiqueta los años con su valor', () {
      expect(StatisticsLabels.forBar(2026, StatisticsPeriod.years), '2026');
    });

    test('usa títulos de eje en plural', () {
      expect(StatisticsLabels.axisTitle(StatisticsPeriod.days), 'Días');
      expect(StatisticsLabels.axisTitle(StatisticsPeriod.months), 'Meses');
      expect(StatisticsLabels.axisTitle(StatisticsPeriod.years), 'Años');
    });
  });
}
