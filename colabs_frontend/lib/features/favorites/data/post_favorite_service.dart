import 'package:dio/dio.dart';
import '../../home/models/post_model.dart';

class PostFavoriteService {
  final Dio _dio;

  PostFavoriteService(this._dio);

  static const String _basePath = '/posts';

  /// Posts likeados por el usuario, ordenados del like más reciente
  Future<PostsResponse> getFavoritePosts({
    required String token,
    int page  = 1,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      '$_basePath/favorites',
      queryParameters: {'page': page, 'limit': limit},
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return PostsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Quita el like de un post
  Future<void> removeLike({
    required String token,
    required String postId,
  }) async {
    await _dio.delete(
      '$_basePath/$postId/like',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }
}
