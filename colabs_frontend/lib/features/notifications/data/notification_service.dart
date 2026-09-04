import 'package:dio/dio.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio;

  NotificationService(this._dio);

  Future<List<NotificationModel>> getEnriched({
    required String token,
  }) async {
    final response = await _dio.get(
      '/notifications/enriched',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    final data = response.data as List<dynamic>;
    return data
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead({
    required String token,
    required String id,
  }) async {
    await _dio.patch(
      '/notifications/$id/read',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }

  Future<void> markAllAsRead({required String token}) async {
    await _dio.patch(
      '/notifications/read-all',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }

  Future<void> delete({
    required String token,
    required String id,
  }) async {
    await _dio.delete(
      '/notifications/$id',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }
}
