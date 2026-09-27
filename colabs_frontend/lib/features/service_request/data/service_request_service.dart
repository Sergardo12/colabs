import 'package:dio/dio.dart';
import '../models/proposal_model.dart';
import '../models/service_request_model.dart';

class ServiceRequestService {
  final Dio _dio;

  ServiceRequestService(this._dio);

  /// Mis solicitudes como demandante
  Future<List<ServiceRequestModel>> getMyRequests({
    required String token,
  }) async {
    final response = await _dio.get(
      '/service-requests/my-requests',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List<dynamic>)
        .map((e) => ServiceRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Solicitudes pendientes cercanas para un colaborador
  /// (el backend filtra por ocupación, radio 5km y excluye auto-solicitudes)
  Future<List<ServiceRequestModel>> getNearbyRequests({
    required String token,
  }) async {
    final response = await _dio.get(
      '/service-requests/nearby',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List<dynamic>)
        .map((e) => ServiceRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Crea una nueva solicitud de servicio
  Future<ServiceRequestModel> createRequest({
    required String token,
    required double lat,
    required double lng,
    required String direction,
    required String occupationId,
    required String description,
    String? profileColabId,
  }) async {
    final response = await _dio.post(
      '/service-requests',
      data: {
        'lat':          lat,
        'lng':          lng,
        'direction':    direction,
        'occupationId': occupationId,
        'description':  description,
        if (profileColabId != null) 'profileColabId': profileColabId,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return ServiceRequestModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Envía una propuesta de precio por una solicitud
  Future<void> sendProposal({
    required String token,
    required String serviceRequestId,
    required double amount,
  }) async {
    await _dio.post(
      '/proposals',
      data: {
        'serviceRequestId': serviceRequestId,
        'amount': amount,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// Propuestas de una solicitud (vista del demandante)
  Future<List<ProposalModel>> getProposals({
    required String token,
    required String requestId,
  }) async {
    final response = await _dio.get(
      '/proposals/request/$requestId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data as List<dynamic>)
        .map((e) => ProposalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Aceptar una propuesta
  Future<void> acceptProposal({
    required String token,
    required String proposalId,
  }) async {
    await _dio.patch(
      '/proposals/$proposalId/accept',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// Rechazar una propuesta
  Future<void> rejectProposal({
    required String token,
    required String proposalId,
  }) async {
    await _dio.patch(
      '/proposals/$proposalId/reject',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// Inicia el trabajo (colaborador ganador: accepted → in_progress)
  Future<void> startWork({
    required String token,
    required String serviceRequestId,
  }) async {
    await _dio.patch(
      '/service-requests/$serviceRequestId/start',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// Finaliza el servicio (colaborador ganador: in_progress → completed)
  Future<void> completeWork({
    required String token,
    required String serviceRequestId,
  }) async {
    await _dio.patch(
      '/service-requests/$serviceRequestId/complete',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// Califica un servicio completado (el comentario es opcional)
  Future<void> submitReview({
    required String token,
    required String serviceRequestId,
    required int rating,
    String? comment,
  }) async {
    await _dio.post(
      '/comment-requests',
      data: {
        'serviceRequestId': serviceRequestId,
        'rating':           rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  /// Ids de solicitudes que ya califiqué como demandante
  /// (GET /comment-requests/my-reviews — persiste tras reiniciar la app)
  Future<Set<String>> getRatedRequestIds({required String token}) async {
    final response = await _dio.get(
      '/comment-requests/my-reviews',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final ids = <String>{};
    for (final item in response.data as List<dynamic>) {
      final serviceRequest =
          (item as Map<String, dynamic>)['serviceRequest'];
      if (serviceRequest is Map<String, dynamic> &&
          serviceRequest['id'] is String) {
        ids.add(serviceRequest['id'] as String);
      }
    }
    return ids;
  }
}
