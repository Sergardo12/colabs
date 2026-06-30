import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/occupation_model.dart';
import 'become_colab_service.dart';

class BecomeColabRepository {
  final BecomeColabService   _becomeColabService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'access_token';

  BecomeColabRepository({
    required BecomeColabService   becomeColabService,
    required FlutterSecureStorage secureStorage,
  })  : _becomeColabService = becomeColabService,
        _secureStorage      = secureStorage;

  /// Lista las ocupaciones disponibles
  Future<List<OccupationItem>> getOccupations() {
    return _becomeColabService.getOccupations();
  }

  /// Convierte al usuario en colaborador
  Future<void> becomeColab({
    required String description,
    required String experience,
    required String dni,
    required List<String> occupationIds,
    String? certifications,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    await _becomeColabService.becomeColab(
      token:          token,
      description:    description,
      experience:     experience,
      dni:            dni,
      occupationIds:  occupationIds,
      certifications: certifications,
    );
  }
}