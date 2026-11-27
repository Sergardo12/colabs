import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colabs_frontend/features/statistics/data/statistics_api_service.dart';
import 'package:colabs_frontend/features/statistics/models/monthly_goal.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.body, {this.headers = const <String, List<String>>{}});

  final String body;
  final Map<String, List<String>> headers;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      200,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}

StatisticsApiService _serviceWith(
  String body, {
  Map<String, List<String>> headers = const <String, List<String>>{},
}) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'));
  dio.httpClientAdapter = _StubAdapter(body, headers: headers);
  return StatisticsApiService(dio);
}

const _jsonHeaders = <String, List<String>>{
  'content-type': <String>['application/json'],
};

void main() {
  group('StatisticsApiService.getMonthlyGoal', () {
    test('cuerpo vacío sin Content-Type devuelve null', () async {
      final service = _serviceWith('');

      await expectLater(service.getMonthlyGoal(), completion(isNull));
    });

    test('JSON válido devuelve MonthlyGoal', () async {
      final service = _serviceWith(
        jsonEncode(<String, dynamic>{
          'amount': 20,
          'offered': 1,
          'month': 11,
          'year': 2026,
        }),
        headers: _jsonHeaders,
      );

      await expectLater(
        service.getMonthlyGoal(),
        completion(
          equals(
            const MonthlyGoal(
              amount: 20,
              offered: 1,
              month: 11,
              year: 2026,
            ),
          ),
        ),
      );
    });

    test('tipo inesperado lanza FormatException', () async {
      final service = _serviceWith(
        jsonEncode('no es una meta'),
        headers: _jsonHeaders,
      );

      await expectLater(
        service.getMonthlyGoal(),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('String'),
          ),
        ),
      );
    });
  });
}
