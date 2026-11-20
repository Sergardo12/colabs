import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'support_service.dart';

class ReportAlreadyReportedException implements Exception {
  const ReportAlreadyReportedException();
}

class SupportRepository {
  final SupportService       _service;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'access_token';

  SupportRepository({
    required SupportService       service,
    required FlutterSecureStorage secureStorage,
  })  : _service       = service,
        _secureStorage = secureStorage;

  Future<String> _getToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return token;
  }

  Future<void> createReport({
    required String category,
    String? reportedUserId,
    String? profileColabId,
    String? serviceRequestId,
    String? description,
  }) async {
    final token = await _getToken();
    try {
      await _service.createReport(
        token:            token,
        category:         category,
        reportedUserId:   reportedUserId,
        profileColabId:   profileColabId,
        serviceRequestId: serviceRequestId,
        description:      description,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const ReportAlreadyReportedException();
      }
      rethrow;
    }
  }

  Future<void> createSuggestion({required String description}) async {
    final token = await _getToken();
    await _service.createSuggestion(token: token, description: description);
  }

  Future<void> createSupport({required String description}) async {
    final token = await _getToken();
    await _service.createSupport(token: token, description: description);
  }
}
