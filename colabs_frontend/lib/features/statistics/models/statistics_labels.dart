import 'package:intl/intl.dart';
import 'statistics_period.dart';

class StatisticsLabels {
  StatisticsLabels._();

  static String forBar(int key, StatisticsPeriod period) {
    return switch (period) {
      StatisticsPeriod.days => _capitalize(
          DateFormat('EEEE', 'es_ES').format(DateTime(2024, 1, key)),
        ),
      StatisticsPeriod.months => _capitalize(
          DateFormat('MMM', 'es_ES')
              .format(DateTime(2024, key))
              .replaceAll('.', ''),
        ),
      StatisticsPeriod.years => key.toString(),
    };
  }

  static String periodTitle(StatisticsPeriod period) {
    return switch (period) {
      StatisticsPeriod.days => 'Días',
      StatisticsPeriod.months => 'Mes',
      StatisticsPeriod.years => 'Año',
    };
  }

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
