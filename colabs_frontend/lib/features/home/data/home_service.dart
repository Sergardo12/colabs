import 'package:dio/dio.dart';
import '../models/post_model.dart';

class HomeService {
  final Dio _dio;

  HomeService(this._dio);

  /// Feed de posts con paginación
  Future<PostsResponse> getFeed({
    required String token,
    int page  = 1,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      '/posts',
      queryParameters: {'page': page, 'limit': limit},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return PostsResponse.fromJson(response.data as Map<String, dynamic>);
  }
}