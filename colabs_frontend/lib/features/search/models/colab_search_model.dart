class ColabSearchModel {
  final String  id;
  final String  userId;
  final String  description;
  final String  experience;
  final String  verificationStatus;
  final double  avgRating;
  final List<ColabOccupation> occupations;
  final ColabUser user;

  const ColabSearchModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.experience,
    required this.verificationStatus,
    this.avgRating = 0.0,
    required this.occupations,
    required this.user,
  });

  factory ColabSearchModel.fromJson(Map<String, dynamic> json) {
    return ColabSearchModel(
      id:                 json['id']                 as String,
      userId:             json['userId']             as String,
      description:        json['description']        as String,
      experience:         json['experience']         as String,
      verificationStatus: json['verificationStatus'] as String,
      avgRating:          (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      occupations: (json['occupations'] as List<dynamic>)
          .map((e) => ColabOccupation.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: ColabUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class ColabOccupation {
  final String  id;
  final String  name;
  final String? image;

  const ColabOccupation({
    required this.id,
    required this.name,
    this.image,
  });

  factory ColabOccupation.fromJson(Map<String, dynamic> json) {
    return ColabOccupation(
      id:    json['id']    as String,
      name:  json['name']  as String,
      image: json['image'] as String?,
    );
  }
}

class ColabUser {
  final String  id;
  final String  name;
  final String  lastName;
  final String? imageProfile;

  const ColabUser({
    required this.id,
    required this.name,
    required this.lastName,
    this.imageProfile,
  });

  factory ColabUser.fromJson(Map<String, dynamic> json) {
    return ColabUser(
      id:           json['id']           as String,
      name:         json['name']         as String,
      lastName:     (json['lastName'] ?? json['last_name']) as String,
      imageProfile: json['imageProfile'] as String?,
    );
  }
}

class ColabSearchResponse {
  final List<ColabSearchModel> data;
  final int                    total;
  final int                    page;
  final int                    lastPage;

  const ColabSearchResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.lastPage,
  });

  factory ColabSearchResponse.fromJson(Map<String, dynamic> json) {
    return ColabSearchResponse(
      data:     (json['data'] as List<dynamic>)
          .map((e) => ColabSearchModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total:    json['total']    as int,
      page:     json['page']     as int,
      lastPage: json['lastPage'] as int,
    );
  }
}