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

  /// Obtiene el feed de posts con paginación
  Future<PostsResponse> getFeed({int page = 1, int limit = 10}) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    return _homeService.getFeed(
      token: token,
      page:  page,
      limit: limit,
    );
  }
}