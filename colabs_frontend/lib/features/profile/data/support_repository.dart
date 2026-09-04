import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'support_service.dart';

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
    required String reportedUserId,
    required String category,
    String? serviceRequestId,
    String? description,
  }) async {
    final token = await _getToken();
    await _service.createReport(
      token:            token,
      reportedUserId:   reportedUserId,
      category:         category,
      serviceRequestId: serviceRequestId,
      description:      description,
    );
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