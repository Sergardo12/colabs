import 'package:dio/dio.dart';

class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  /// Obtiene el perfil del usuario autenticado
  Future<Map<String, dynamic>> getMyProfile({
    required String token,
  }) async {
    final response = await _dio.get(
      '/auth/me',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Obtiene el perfil de colaborador del usuario autenticado
  /// Retorna null si el usuario no es colaborador
  Future<Map<String, dynamic>?> getMyColabProfile({
    required String token,
  }) async {
    try {
      final response = await _dio.get(
        '/profile-colab/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Obtiene el perfil público de un usuario por ID
  Future<Map<String, dynamic>> getPublicProfile({
    required String token,
    required String userId,
  }) async {
    final response = await _dio.get(
      '/users/$userId',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return response.data as Map<String, dynamic>;
  }
}