import 'package:dio/dio.dart';

class SupportService {
  final Dio _dio;

  SupportService(this._dio);

  Future<void> createReport({
    required String token,
    required String reportedUserId,
    required String category,
    String? serviceRequestId,
    String? description,
  }) async {
    await _dio.post(
      '/reports',
      data: {
        'reportedUserId':   reportedUserId,
        'category':         category,
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