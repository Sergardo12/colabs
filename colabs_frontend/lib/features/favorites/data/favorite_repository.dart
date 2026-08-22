import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../search/models/colab_search_model.dart';
import 'favorite_service.dart';

class FavoriteRepository {
  final FavoriteService       _favoriteService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'access_token';

  FavoriteRepository({
    required FavoriteService      favoriteService,
    required FlutterSecureStorage secureStorage,
  })  : _favoriteService = favoriteService,
        _secureStorage = secureStorage;

  Future<List<ColabSearchModel>> getFavorites() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    return _favoriteService.getFavorites(token: token);
  }

  Future<void> addFavorite(String profileColabId) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    return _favoriteService.addFavorite(
      token:          token,
      profileColabId: profileColabId,
    );
  }

  Future<void> removeFavorite(String profileColabId) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    return _favoriteService.removeFavorite(
      token:          token,
      profileColabId: profileColabId,
    );
  }
}
