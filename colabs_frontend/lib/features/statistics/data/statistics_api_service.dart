import 'package:dio/dio.dart';
import '../models/monthly_goal.dart';
import '../models/services_offered_response.dart';
import '../models/services_rate.dart';
import '../models/statistics_period.dart';

class StatisticsApiService {
  final Dio _dio;

  StatisticsApiService(this._dio);

  Future<ServicesOfferedResponse> getServicesOffered(StatisticsPeriod period) async {
    final response = await _dio.get(
      '/statistics/services-offered',
      queryParameters: {'period': period.key},
    );
    return ServicesOfferedResponse.fromJson(
      _requireJsonMap(response.data, 'services-offered'),
    );
  }

  Future<int> getServicesTotal(StatisticsPeriod period) async {
    final response = await _dio.get(
      '/statistics/services-total',
      queryParameters: {'period': period.key},
    );
    final data = _requireJsonMap(response.data, 'services-total');
    return (data['total'] as num).toInt();
  }

  Future<ServicesRate> getServicesRate() async {
    final response = await _dio.get('/statistics/services-rate');
    return ServicesRate.fromJson(
      _requireJsonMap(response.data, 'services-rate'),
    );
  }

  Future<double?> getAverageRating() async {
    final response = await _dio.get('/statistics/average-rating');
    final data = _requireJsonMap(response.data, 'average-rating');
    final value = data['averageRating'];
    return (value as num?)?.toDouble();
  }

  Future<MonthlyGoal?> getMonthlyGoal() async {
    final response = await _dio.get('/statistics/monthly-goal');
    final data = response.data;
    if (data == null || (data is String && data.trim().isEmpty)) return null;
    return MonthlyGoal.fromJson(_requireJsonMap(data, 'monthly-goal'));
  }

  Future<MonthlyGoal> saveMonthlyGoal(int amount) async {
    final response = await _dio.post(
      '/statistics/monthly-goal',
      data: {'amount': amount},
    );
    return MonthlyGoal.fromJson(
      _requireJsonMap(response.data, 'monthly-goal'),
    );
  }

  Map<String, dynamic> _requireJsonMap(Object? data, String endpoint) {
    if (data is Map<String, dynamic>) return data;
    throw FormatException(
      'Respuesta inesperada de $endpoint: ${data?.runtimeType ?? 'null'}',
    );
  }
}
