/// Reseña del perfil público de un colaborador.
/// Mapea la respuesta de GET /comment-requests/colab/:profileColabId.
class ReviewModel {
  final String        id;
  final int           rating;
  final String?       comment;
  final String        creationDate;
  final ReviewAuthor? author;
  final String        occupationName;

  const ReviewModel({
    required this.id,
    required this.rating,
    this.comment,
    this.creationDate = '',
    this.author,
    this.occupationName = '',
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final serviceRequest = json['serviceRequest'] as Map<String, dynamic>?;
    final occupation = serviceRequest?['occupation'] as Map<String, dynamic>?;
    final rawUser = json['user'] as Map<String, dynamic>?;

    return ReviewModel(
      id:       json['id']       as String,
      rating:   json['rating']   as int,
      comment:  json['comment']  as String?,
      creationDate: (json['creationDate'] ?? json['creation_date'] ?? '')
          as String,
      author: rawUser != null ? ReviewAuthor.fromJson(rawUser) : null,
      occupationName: occupation?['name'] as String? ?? '',
    );
  }
}

class ReviewAuthor {
  final String  id;
  final String  name;
  final String  lastName;
  final String? imageProfile;

  const ReviewAuthor({
    required this.id,
    required this.name,
    required this.lastName,
    this.imageProfile,
  });

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) {
    return ReviewAuthor(
      id:           json['id']                 as String,
      name:         json['name']               as String,
      lastName:     (json['lastName'] ?? json['last_name']) as String,
      imageProfile: json['imageProfile']       as String?,
    );
  }
}

/// Respuesta agregada de calificaciones de un colaborador.
class ReviewsResponse {
  final double          averageRating;
  final int             totalReviews;
  final List<ReviewModel> comments;

  const ReviewsResponse({
    this.averageRating = 0,
    this.totalReviews = 0,
    this.comments = const [],
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    final rawComments = (json['comments'] as List<dynamic>?) ?? const [];

    return ReviewsResponse(
      averageRating: (json['averageRating'] as num? ?? 0).toDouble(),
      totalReviews:  json['totalReviews'] as int? ?? 0,
      comments:      rawComments
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
