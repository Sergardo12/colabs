import 'package:dio/dio.dart';
import '../../search/models/colab_search_model.dart';

class FavoriteService {
  final Dio _dio;

  FavoriteService(this._dio);

  static const String _basePath = '/favorites';

  /// Lista de colaboradores favoritos del usuario
  Future<List<ColabSearchModel>> getFavorites({
    required String token,
  }) async {
    final response = await _dio.get(
      _basePath,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    return (response.data['data'] as List<dynamic>)
        .map((e) => ColabSearchModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Agrega un colaborador a favoritos
  Future<void> addFavorite({
    required String token,
    required String profileColabId,
  }) async {
    await _dio.post(
      '$_basePath/$profileColabId',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }

  /// Quita un colaborador de favoritos
  Future<void> removeFavorite({
    required String token,
    required String profileColabId,
  }) async {
    await _dio.delete(
      '$_basePath/$profileColabId',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }
}
