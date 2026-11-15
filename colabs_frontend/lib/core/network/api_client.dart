import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._();

  // Se puede sobreescribir: --dart-define=API_HOST=http://192.168.1.10:8080
  static const String host =
      String.fromEnvironment('API_HOST', defaultValue: 'http://localhost:8080');

  static Dio create() => Dio(BaseOptions(
        baseUrl: '$host/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));
}