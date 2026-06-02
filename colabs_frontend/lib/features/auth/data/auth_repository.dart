import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class AuthRepository {
  final AuthService          _authService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'access_token';

  AuthRepository({
    required AuthService          authService,
    required FlutterSecureStorage secureStorage,
  })  : _authService    = authService,
        _secureStorage  = secureStorage;

  /// Login — llama al service, guarda el JWT y retorna el usuario
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _authService.login(
      email:    email,
      password: password,
    );

    // Guarda el JWT de forma segura en el dispositivo
    await _secureStorage.write(
      key:   _tokenKey,
      value: data['access_token'] as String,
    );

    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Register — llama al service, guarda el JWT y retorna el usuario
  Future<UserModel> register({
    required String email,
    required String name,
    required String lastName,
    required String password,
    required String phoneNumber,
  }) async {
    final data = await _authService.register(
      email:       email,
      name:        name,
      lastName:    lastName,
      password:    password,
      phoneNumber: phoneNumber,
    );

    await _secureStorage.write(
      key:   _tokenKey,
      value: data['access_token'] as String,
    );

    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Verifica si el JWT guardado sigue siendo válido
Future<bool> isSessionValid() async {
  final token = await getToken();
  if (token == null) return false;
  return _authService.verifyToken(token);
}

  /// Lee el JWT guardado — lo usa el Splash para verificar sesión
  Future<String?> getToken() async {
    return _secureStorage.read(key: _tokenKey);
  }

  /// Elimina el JWT — logout
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }
}