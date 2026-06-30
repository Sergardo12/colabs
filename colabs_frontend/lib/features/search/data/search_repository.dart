import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/colab_search_model.dart';
import 'search_service.dart';

class SearchRepository {
  final SearchService        _searchService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'access_token';

  SearchRepository({
    required SearchService        searchService,
    required FlutterSecureStorage secureStorage,
  })  : _searchService = searchService,
        _secureStorage = secureStorage;

  /// Busca colaboradores por nombre u ocupación
  Future<ColabSearchResponse> searchColabs({
    String? name,
    String? occupation,
    int page  = 1,
    int limit = 10,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    return _searchService.searchColabs(
      token:      token,
      name:       name,
      occupation: occupation,
      page:       page,
      limit:      limit,
    );
  }
}