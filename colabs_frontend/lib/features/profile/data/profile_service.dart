import 'package:dio/dio.dart';
import '../models/occupation_model.dart';

class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  /// Lista todas las ocupaciones activas — endpoint público
  Future<List<OccupationItem>> getOccupations() async {
    final response = await _dio.get('/occupations');
    return (response.data as List<dynamic>)
        .map((e) => OccupationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

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

  /// Actualiza los datos del usuario
  Future<Map<String, dynamic>> updateUserProfile({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.patch(
      '/users/profile',
      data: data,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return response.data as Map<String, dynamic>;
  }

  /// Actualiza el perfil de colaborador
  Future<Map<String, dynamic>> updateColabProfile({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.patch(
      '/profile-colab/me',
      data: data,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return response.data as Map<String, dynamic>;
  }
}