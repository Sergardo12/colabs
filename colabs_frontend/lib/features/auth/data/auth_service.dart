import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  /// Login con email y contraseña
  /// Retorna access_token y datos del usuario
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email':    email,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Registro de nuevo usuario
  /// Retorna access_token y datos del usuario
  Future<Map<String, dynamic>> register({
    required String email,
    required String name,
    required String lastName,
    required String password,
    required String phoneNumber,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {
        'email':       email,
        'name':        name,
        'lastName':    lastName,
        'password':    password,
        'phoneNumber': phoneNumber,
      },
    );
    return response.data as Map<String, dynamic>;
  }
/// Verifica si el JWT es válido — llama a /auth/me
  Future<bool> verifyToken(String token) async {
  try {
    await _dio.get(
      '/auth/me',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return true;
  } catch (_) {
    return false;
  }
  }
}