import '../models/monthly_goal.dart';
import '../models/services_offered_response.dart';
import '../models/services_rate.dart';
import '../models/statistics_period.dart';
import 'statistics_api_service.dart';
import 'statistics_repository.dart';

class StatisticsApiRepository implements StatisticsRepository {
  final StatisticsApiService _service;

  StatisticsApiRepository(this._service);

  @override
  Future<ServicesOfferedResponse> getServicesOffered(StatisticsPeriod period) =>
      _service.getServicesOffered(period);

  @override
  Future<int> getServicesTotal(StatisticsPeriod period) =>
      _service.getServicesTotal(period);

  @override
  Future<ServicesRate> getServicesRate() => _service.getServicesRate();

  @override
  Future<double?> getAverageRating() => _service.getAverageRating();

  @override
  Future<MonthlyGoal?> getMonthlyGoal() => _service.getMonthlyGoal();

  @override
  Future<MonthlyGoal> saveMonthlyGoal(int amount) =>
      _service.saveMonthlyGoal(amount);
}
