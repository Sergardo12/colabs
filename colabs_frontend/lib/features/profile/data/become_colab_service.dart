import 'package:dio/dio.dart';
import '../models/occupation_model.dart';

class BecomeColabService {
  final Dio _dio;

  BecomeColabService(this._dio);

  /// Lista todas las ocupaciones activas — endpoint público
  Future<List<OccupationItem>> getOccupations() async {
    final response = await _dio.get('/occupations');
    return (response.data as List<dynamic>)
        .map((e) => OccupationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Convierte al usuario en colaborador
  Future<void> becomeColab({
    required String token,
    required String description,
    required String experience,
    required String dni,
    required List<String> occupationIds,
    String? certifications,
  }) async {
    await _dio.post(
      '/profile-colab',
      data: {
        'description':    description,
        'experience':     experience,
        'dni':            dni,
        'occupationIds':  occupationIds,
        if (certifications != null && certifications.isNotEmpty)
          'certifications': certifications,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }
}