import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        // 10.0.2.2 = localhost del host desde el emulador Android
        baseUrl:        'http://10.0.2.2:8080/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept':       'application/json',
        },
      ),
    );
    return dio;
  }
}