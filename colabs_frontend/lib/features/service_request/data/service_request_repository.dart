import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/service_request_model.dart';
import 'service_request_service.dart';

class ServiceRequestRepository {
  final ServiceRequestService _service;
  final FlutterSecureStorage  _secureStorage;

  static const String _tokenKey = 'access_token';

  ServiceRequestRepository({
    required ServiceRequestService service,
    required FlutterSecureStorage  secureStorage,
  })  : _service       = service,
        _secureStorage = secureStorage;

  Future<List<ServiceRequestModel>> getMyRequests() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.getMyRequests(token: token);
  }

  Future<ServiceRequestModel> createRequest({
    required double lat,
    required double lng,
    required String direction,
    required String occupationId,
    required String description,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.createRequest(
      token:        token,
      lat:          lat,
      lng:          lng,
      direction:    direction,
      occupationId: occupationId,
      description:  description,
    );
  }
}
