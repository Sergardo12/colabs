import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/proposal_model.dart';
import '../models/reportable_service_model.dart';
import '../models/service_request_model.dart';
import 'rejected_nearby_requests_store.dart';
import 'service_request_service.dart';

class ServiceRequestRepository {
  final ServiceRequestService _service;
  final FlutterSecureStorage  _secureStorage;
  final RejectedNearbyRequestsStore _rejectedStore;

  static const String _tokenKey = 'access_token';

  ServiceRequestRepository({
    required ServiceRequestService service,
    required FlutterSecureStorage  secureStorage,
    RejectedNearbyRequestsStore? rejectedStore,
  })  : _service       = service,
        _secureStorage = secureStorage,
        _rejectedStore = rejectedStore ?? RejectedNearbyRequestsStore();

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

  Future<List<ReportableServiceModel>> getCancelledWithColab({
    String? search,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.getCancelledWithColab(token: token, search: search);
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

  Future<void> startWork(String serviceRequestId) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.startWork(
      token:            token,
      serviceRequestId: serviceRequestId,
    );
  }

  Future<void> completeWork(String serviceRequestId) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.completeWork(
      token:            token,
      serviceRequestId: serviceRequestId,
    );
  }

  Future<void> cancelRequest(String serviceRequestId) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.cancelRequest(
      token:            token,
      serviceRequestId: serviceRequestId,
    );
  }

  Future<ServiceRequestModel> reloadRequest(String serviceRequestId) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.reloadRequest(
      token:            token,
      serviceRequestId: serviceRequestId,
    );
  }

  /// IDs de solicitudes cercanas rechazadas por el colaborador actual.
  /// Se guardan localmente y solo filtran su vista (HEAD 4).
  Future<Set<String>> getHiddenNearbyRequestIds() async {
    final userId = await _currentUserId();
    return _rejectedStore.load(userId);
  }

  Future<void> hideNearbyRequest(String requestId) async {
    final userId = await _currentUserId();
    await _rejectedStore.add(userId, requestId);
  }

  Future<String> _currentUserId() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) return 'anonymous';

    try {
      final parts = token.split('.');
      if (parts.length < 2) return 'anonymous';
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is Map<String, dynamic> && payload['sub'] is String) {
        return payload['sub'] as String;
      }
    } catch (_) {
      // Token malformado: se usa una clave global para no bloquear la vista.
    }
    return 'anonymous';
  }

  Future<void> submitReview({
    required String serviceRequestId,
    required int rating,
    String? comment,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.submitReview(
      token:            token,
      serviceRequestId: serviceRequestId,
      rating:           rating,
      comment:          comment,
    );
  }

  Future<Set<String>> getRatedRequestIds() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');
    return _service.getRatedRequestIds(token: token);
  }
}
