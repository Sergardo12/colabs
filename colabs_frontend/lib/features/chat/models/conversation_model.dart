import '../../home/models/post_model.dart';

class ConversationUser {
  final String  id;
  final String  name;
  final String  lastName;
  final String? imageProfile;

  const ConversationUser({
    required this.id,
    required this.name,
    required this.lastName,
    this.imageProfile,
  });

  factory ConversationUser.fromJson(Map<String, dynamic> json) {
    return ConversationUser(
      id:           json['id']           as String,
      name:         json['name']         as String,
      lastName:     (json['lastName'] ?? json['last_name']) as String,
      imageProfile: json['imageProfile'] as String?,
    );
  }
}

class ConversationColabUser {
  final String  id;
  final String  name;
  final String  lastName;
  final String? imageProfile;

  const ConversationColabUser({
    required this.id,
    required this.name,
    required this.lastName,
    this.imageProfile,
  });

  factory ConversationColabUser.fromJson(Map<String, dynamic> json) {
    return ConversationColabUser(
      id:           json['id']           as String,
      name:         json['name']         as String,
      lastName:     (json['lastName'] ?? json['last_name']) as String,
      imageProfile: json['imageProfile'] as String?,
    );
  }
}

class ConversationProfileColab {
  final String               id;
  final ConversationColabUser user;

  const ConversationProfileColab({
    required this.id,
    required this.user,
  });

  factory ConversationProfileColab.fromJson(Map<String, dynamic> json) {
    return ConversationProfileColab(
      id:   json['id'] as String,
      user: ConversationColabUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class ConversationModel {
  final String                id;
  final String                status;
  final String                createdAt;
  final String                userId;
  final String                profileColabId;
  final String?               postId;
  final String?               serviceRequestId;
  final ConversationProfileColab profileColab;
  final ConversationUser?     user;
  final PostModel?            post;

  const ConversationModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.userId,
    required this.profileColabId,
    this.postId,
    this.serviceRequestId,
    required this.profileColab,
    this.user,
    this.post,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id:               json['id']               as String,
      status:           json['status']           as String,
      createdAt:        json['createdAt']         as String,
      userId:           json['userId']            as String,
      profileColabId:   json['profileColabId']    as String,
      postId:           json['postId']            as String?,
      serviceRequestId: json['serviceRequestId']  as String?,
      profileColab:     ConversationProfileColab.fromJson(
                          json['profileColab'] as Map<String, dynamic>),
      user: json['user'] != null
          ? ConversationUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      post: json['post'] != null
          ? PostModel.fromConversationJson(
              json['post'] as Map<String, dynamic>)
          : null,
    );
  }
}
