import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../home/models/post_model.dart';
import 'post_favorite_service.dart';

class PostFavoriteRepository {
  final PostFavoriteService     _postFavoriteService;
  final FlutterSecureStorage    _secureStorage;

  static const String _tokenKey = 'access_token';

  PostFavoriteRepository({
    required PostFavoriteService  postFavoriteService,
    required FlutterSecureStorage secureStorage,
  })  : _postFavoriteService = postFavoriteService,
        _secureStorage       = secureStorage;

  /// Posts favoritos del usuario con paginación
  Future<PostsResponse> getFavoritePosts({
    int page  = 1,
    int limit = 10,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    return _postFavoriteService.getFavoritePosts(
      token: token,
      page:  page,
      limit: limit,
    );
  }

  /// Quita el like de un post
  /// Un 404 del servidor (ya sin like) se sincroniza como éxito — idempotente
  Future<void> removeLike(String postId) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    try {
      await _postFavoriteService.removeLike(token: token, postId: postId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return;
      rethrow;
    }
  }
}
