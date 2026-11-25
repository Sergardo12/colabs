import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(key: 'access_token');
    if (token != null && options.headers['Authorization'] == null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
