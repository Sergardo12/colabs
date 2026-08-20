import 'package:dio/dio.dart';
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
}
