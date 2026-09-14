import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/proposal_model.dart';
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

  Future<List<ServiceRequestModel>> getNearbyRequests() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.getNearbyRequests(token: token);
  }

  Future<ServiceRequestModel> createRequest({
    required double lat,
    required double lng,
    required String direction,
    required String occupationId,
    required String description,
    String? profileColabId,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.createRequest(
      token:          token,
      lat:            lat,
      lng:            lng,
      direction:      direction,
      occupationId:   occupationId,
      description:    description,
      profileColabId: profileColabId,
    );
  }

  Future<void> sendProposal({
    required String serviceRequestId,
    required double amount,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.sendProposal(
      token:            token,
      serviceRequestId: serviceRequestId,
      amount:           amount,
    );
  }

  Future<List<ProposalModel>> getProposals(String requestId) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.getProposals(token: token, requestId: requestId);
  }

  Future<void> acceptProposal(String proposalId) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.acceptProposal(token: token, proposalId: proposalId);
  }

  Future<void> rejectProposal(String proposalId) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.rejectProposal(token: token, proposalId: proposalId);
  }
}
