import 'package:dio/dio.dart';

class SupportService {
  final Dio _dio;

  SupportService(this._dio);

  Future<void> createReport({
    required String token,
    required String category,
    String? reportedUserId,
    String? profileColabId,
    String? serviceRequestId,
    String? description,
  }) async {
    await _dio.post(
      '/reports',
      data: {
        'category': category,
        if (reportedUserId != null) 'reportedUserId': reportedUserId,
        if (profileColabId != null) 'profileColabId': profileColabId,
        if (serviceRequestId != null)
          'serviceRequestId': serviceRequestId,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> createSuggestion({
    required String token,
    required String description,
  }) async {
    await _dio.post(
      '/suggestions',
      data: {'description': description},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> createSupport({
    required String token,
    required String description,
  }) async {
    await _dio.post(
      '/support',
      data: {'description': description},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}