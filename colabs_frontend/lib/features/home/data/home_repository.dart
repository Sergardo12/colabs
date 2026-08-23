import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/post_model.dart';
import 'home_service.dart';

class HomeRepository {
  final HomeService          _homeService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'access_token';

  HomeRepository({
    required HomeService          homeService,
    required FlutterSecureStorage secureStorage,
  })  : _homeService    = homeService,
        _secureStorage  = secureStorage;

  /// Obtiene el feed de posts con paginación.
  /// Si `profileColabId` viene, filtra los posts de ese colaborador.
  Future<PostsResponse> getFeed({
    int page = 1,
    int limit = 10,
    String? profileColabId,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    return _homeService.getFeed(
      token:           token,
      page:            page,
      limit:           limit,
      profileColabId:  profileColabId,
    );
  }

  /// Da like a un post
  /// Un 403 del servidor (ya tiene like) se sincroniza como éxito — idempotente
  Future<void> likePost(String postId) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    try {
      await _homeService.likePost(token: token, postId: postId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) return;
      rethrow;
    }
  }

  /// Quita el like de un post
  /// Un 404 del servidor (ya sin like) se sincroniza como éxito — idempotente
  Future<void> unlikePost(String postId) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    try {
      await _homeService.unlikePost(token: token, postId: postId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return;
      rethrow;
    }
  }
}