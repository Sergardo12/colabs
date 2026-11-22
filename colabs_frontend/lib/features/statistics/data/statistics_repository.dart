import '../models/statistics_data.dart';
import '../models/statistics_period.dart';

abstract class StatisticsRepository {
  Future<StatisticsData> getStatistics(StatisticsPeriod period);

  Future<void> saveMonthlyGoal(int amount);
}
