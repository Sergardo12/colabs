import 'package:dio/dio.dart';
import '../models/colab_search_model.dart';

class SearchService {
  final Dio _dio;

  SearchService(this._dio);

  /// Busca colaboradores por nombre u ocupación con paginación
  Future<ColabSearchResponse> searchColabs({
    required String token,
    String? name,
    String? occupation,
    int page  = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page':  page,
      'limit': limit,
    };

    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }
    if (occupation != null && occupation.isNotEmpty) {
      queryParams['occupation'] = occupation;
    }

    final response = await _dio.get(
      '/profile-colab/search',
      queryParameters: queryParams,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return ColabSearchResponse.fromJson(response.data as Map<String, dynamic>);
  }
}