import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../home/data/home_service.dart';
import '../../home/models/post_model.dart';
import '../../profile/data/profile_service.dart';
import '../models/public_colab_model.dart';
import '../models/review_model.dart';

/// Repositorio del perfil público del colaborador.
/// Envuelve ProfileService + HomeService y el token de sesión.
class PublicProfileRepository {
  final ProfileService       _profileService;
  final HomeService          _homeService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'access_token';

  PublicProfileRepository({
    required ProfileService       profileService,
    required HomeService          homeService,
    required FlutterSecureStorage secureStorage,
  })  : _profileService = profileService,
        _homeService    = homeService,
        _secureStorage  = secureStorage;

  /// Header del perfil público (usuario + perfil de colaborador)
  Future<PublicColabModel> getPublicColabProfile({
    required String userId,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    final json = await _profileService.getPublicProfile(
      token:  token,
      userId: userId,
    );
    return PublicColabModel.fromJson(json);
  }

  /// Calificaciones/reseñas del colaborador
  Future<ReviewsResponse> getProfileReviews({
    required String profileColabId,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    final json = await _profileService.getProfileReviews(
      token:          token,
      profileColabId: profileColabId,
    );
    return ReviewsResponse.fromJson(json);
  }

  /// Posts del colaborador con paginación
  Future<PostsResponse> getProfilePosts({
    required String profileColabId,
    int page  = 1,
    int limit = 10,
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
}
