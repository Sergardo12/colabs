import '../../../core/constants/app_strings.dart';
import 'statistics_period.dart';

class StatisticsLabels {
  StatisticsLabels._();

  static const List<String> _days = <String>[
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  static const List<String> _months = <String>[
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  static String forBar(int key, StatisticsPeriod period) {
    return switch (period) {
      StatisticsPeriod.days => _days[(key - 1).clamp(0, _days.length - 1)],
      StatisticsPeriod.months =>
        _months[(key - 1).clamp(0, _months.length - 1)],
      StatisticsPeriod.years => key.toString(),
    };
  }

  static String periodTitle(StatisticsPeriod period) {
    return switch (period) {
      StatisticsPeriod.days => AppStrings.periodDays,
      StatisticsPeriod.months => AppStrings.periodMonths,
      StatisticsPeriod.years => AppStrings.periodYears,
    };
  }

  static String axisTitle(StatisticsPeriod period) {
    return switch (period) {
      StatisticsPeriod.days => AppStrings.axisDays,
      StatisticsPeriod.months => AppStrings.axisMonths,
      StatisticsPeriod.years => AppStrings.axisYears,
    };
  }
}
