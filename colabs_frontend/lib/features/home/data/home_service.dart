import 'package:dio/dio.dart';
import '../models/post_model.dart';

class HomeService {
  final Dio _dio;

  HomeService(this._dio);

  /// Feed de posts con paginación.
  /// Si `profileColabId` viene, filtra los posts de ese colaborador.
  Future<PostsResponse> getFeed({
    required String token,
    int page  = 1,
    int limit = 10,
    String? profileColabId,
  }) async {
    final response = await _dio.get(
      '/posts',
      queryParameters: {
        'page':  page,
        'limit': limit,
        if (profileColabId != null) 'profileColabId': profileColabId,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return PostsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Da like a un post
  Future<void> likePost({
    required String token,
    required String postId,
  }) async {
    await _dio.post(
      '/posts/$postId/like',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }

  /// Quita el like de un post
  Future<void> unlikePost({
    required String token,
    required String postId,
  }) async {
    await _dio.delete(
      '/posts/$postId/like',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }
}