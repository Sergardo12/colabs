import '../models/monthly_goal.dart';
import '../models/services_offered_response.dart';
import '../models/services_rate.dart';
import '../models/statistics_period.dart';

abstract class StatisticsRepository {
  Future<ServicesOfferedResponse> getServicesOffered(StatisticsPeriod period);

  Future<int> getServicesTotal(StatisticsPeriod period);

  Future<ServicesRate> getServicesRate();

  Future<double?> getAverageRating();

  Future<MonthlyGoal?> getMonthlyGoal();

  Future<MonthlyGoal> saveMonthlyGoal(int amount);
}
