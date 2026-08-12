import '../../profile/models/profile_model.dart';

/// Perfil público de un usuario. Tolerante a la respuesta reducida
/// de GET /users/:id cuando el usuario es demandante (sin profileColab).
class PublicColabModel {
  final String  id;
  final String  name;
  final String  lastName;
  final String? imageProfile;
  final String  registrationDate;

  /// Perfil de colaborador — null si el usuario es demandante
  final String? colabId;
  final String? description;
  final String? experience;
  final String  verificationStatus;
  final List<OccupationModel> occupations;

  const PublicColabModel({
    required this.id,
    required this.name,
    required this.lastName,
    this.imageProfile,
    this.registrationDate = '',
    this.colabId,
    this.description,
    this.experience,
    this.verificationStatus = 'pending',
    this.occupations = const [],
  });

  bool get isCollaborator => colabId != null;

  factory PublicColabModel.fromJson(Map<String, dynamic> json) {
    final profileColab = json['profileColab'] as Map<String, dynamic>?;
    final rawOccupations =
        (profileColab?['occupations'] as List<dynamic>?) ?? const [];

    return PublicColabModel(
      id:               json['id']                 as String,
      name:             json['name']               as String,
      lastName:         (json['lastName'] ?? json['last_name']) as String,
      imageProfile:     json['imageProfile']       as String?,
      registrationDate: (json['registrationDate'] ??
              json['registration_date'] ??
              json['createdAt'] ??
              '') as String,
      colabId:           profileColab?['id']                       as String?,
      description:       profileColab?['description']              as String?,
      experience:        profileColab?['experience']               as String?,
      verificationStatus:
          (profileColab?['verificationStatus'] as String?) ?? 'pending',
      occupations: rawOccupations
          .map((e) => OccupationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Estadísticas agregadas del perfil público.
/// Se arma en el BLoC a partir de PostsResponse y ReviewsResponse.
class PublicProfileStats {
  final int    postCount;
  final double averageRating;
  final int    totalReviews;
  final int    totalLikes;

  const PublicProfileStats({
    this.postCount = 0,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.totalLikes = 0,
  });

  PublicProfileStats copyWith({
    int?    postCount,
    double? averageRating,
    int?    totalReviews,
    int?    totalLikes,
  }) {
    return PublicProfileStats(
      postCount:     postCount     ?? this.postCount,
      averageRating: averageRating ?? this.averageRating,
      totalReviews:  totalReviews  ?? this.totalReviews,
      totalLikes:    totalLikes    ?? this.totalLikes,
    );
  }
}
