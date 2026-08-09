import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/profile_model.dart';
import '../models/occupation_model.dart';
import 'profile_service.dart';

class ProfileRepository {
  final ProfileService       _profileService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'access_token';

  ProfileRepository({
    required ProfileService       profileService,
    required FlutterSecureStorage secureStorage,
  })  : _profileService = profileService,
        _secureStorage  = secureStorage;

  /// Obtiene el perfil completo del usuario autenticado
  /// Incluye perfil de colaborador si existe
  Future<({UserProfileModel user, ColabProfileModel? colab})> getMyProfile() async {
  final token = await _secureStorage.read(key: _tokenKey);
  if (token == null) throw Exception('No hay sesión activa');

  try {
    final userJson  = await _profileService.getMyProfile(token: token);
    final colabJson = await _profileService.getMyColabProfile(token: token);

    return (
      user:  UserProfileModel.fromJson(userJson),
      colab: colabJson != null
          ? ColabProfileModel.fromJson(colabJson)
          : null,
    );
  } catch (e) {
    print('ERROR PROFILE: $e');
    rethrow;
  }
}

  /// Obtiene el perfil público de un usuario por ID
  Future<UserProfileModel> getPublicProfile({required String userId}) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    final json = await _profileService.getPublicProfile(
      token:  token,
      userId: userId,
    );
    return UserProfileModel.fromJson(json);
  }

  /// Lista todas las ocupaciones disponibles
  Future<List<OccupationItem>> getOccupations() {
    return _profileService.getOccupations();
  }

  /// Actualiza los datos del usuario
  Future<void> updateUserProfile({
    required String name,
    required String lastName,
    required String phoneNumber,
    String? dateBirth,
    String? gender,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    final data = <String, dynamic>{
      'name':        name,
      'lastName':    lastName,
      'phoneNumber': phoneNumber,
    };
    if (dateBirth != null) data['dateBirth'] = dateBirth;
    if (gender != null) data['gender'] = gender;

    await _profileService.updateUserProfile(token: token, data: data);
  }

  /// Actualiza el perfil de colaborador
  Future<void> updateColabProfile({
    required String description,
    required String experience,
    required List<String> occupationIds,
    String? certifications,
  }) async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) throw Exception('No hay sesión activa');

    final data = <String, dynamic>{
      'description':   description,
      'experience':    experience,
      'occupationIds': occupationIds,
    };
    if (certifications != null && certifications.isNotEmpty) {
      data['certifications'] = certifications;
    }

    await _profileService.updateColabProfile(token: token, data: data);
  }
}