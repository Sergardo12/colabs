class PostAuthor {
  final String id;
  final String name;
  final String lastName;
  final String? imageProfile;

  const PostAuthor({
    required this.id,
    required this.name,
    required this.lastName,
    this.imageProfile,
  });

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    return PostAuthor(
      id: json['id'] as String,
      name: json['name'] as String,
      lastName: json['lastName'] as String,
      imageProfile: json['imageProfile'] as String?,
    );
  }
}

class PostOccupation {
  final String id;
  final String name;
  final String? image;

  const PostOccupation({required this.id, required this.name, this.image});

  factory PostOccupation.fromJson(Map<String, dynamic> json) {
    return PostOccupation(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
    );
  }
}

class PostModel {
  final String id;
  final String profileColabId;
  final String description;
  final String price;
  final List<String> media;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final String createdAt;
  final PostAuthor author;
  final PostOccupation occupation;

  const PostModel({
    required this.id,
    required this.profileColabId,
    required this.description,
    required this.price,
    required this.media,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.createdAt,
    required this.author,
    required this.occupation,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final profileColab = json['profileColab'] as Map<String, dynamic>;
    final user = profileColab['user'] as Map<String, dynamic>;
    final occupations = profileColab['occupations'] as List<dynamic>;

    return PostModel(
      id: json['id'] as String,
      profileColabId: profileColab['id'] as String,
      description: json['description'] as String,
      price: json['price'] as String,
      media: (json['media'] as List<dynamic>).cast<String>(),
      likesCount: json['likesCount'] as int,
      commentsCount: json['commentsCount'] as int,
      isLiked: json['isLiked'] as bool,
      createdAt: json['createdAt'] as String,
      author: PostAuthor.fromJson(user),
      occupation: occupations.isNotEmpty
          ? PostOccupation.fromJson(occupations.first as Map<String, dynamic>)
          : const PostOccupation(id: '', name: 'Sin ocupación'),
    );
  }

  /// Usado cuando el post viene embebido en una conversación
  /// No tiene profileColab, likesCount, commentsCount ni isLiked
  factory PostModel.fromConversationJson(Map<String, dynamic> json) {
    return PostModel(
      id:           json['id']          as String,
      profileColabId: '',
      description:  json['description'] as String,
      price:        (json['price'] ?? '0').toString(),
      media:        json['media'] != null
                      ? (json['media'] as List<dynamic>).cast<String>()
                      : [],
      likesCount:   0,
      commentsCount: 0,
      isLiked:      false,
      createdAt:    json['createdAt']   as String,
      author:       const PostAuthor(
                      id: '', name: '', lastName: ''),
      occupation:   const PostOccupation(id: '', name: ''),
    );
  }
}

class PostsResponse {
  final List<PostModel> data;
  final int total;
  final int page;
  final int lastPage;

  const PostsResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.lastPage,
  });

  factory PostsResponse.fromJson(Map<String, dynamic> json) {
    return PostsResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      lastPage: json['lastPage'] as int,
    );
  }
}
