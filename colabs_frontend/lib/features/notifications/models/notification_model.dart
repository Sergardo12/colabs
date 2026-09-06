class NotificationRequester {
  final String? id;
  final String? name;
  final String? lastName;
  final String? imageProfile;

  const NotificationRequester({
    this.id,
    this.name,
    this.lastName,
    this.imageProfile,
  });

  factory NotificationRequester.fromJson(Map<String, dynamic> json) {
    return NotificationRequester(
      id: json['id'] as String?,
      name: json['name'] as String?,
      lastName: json['lastName'] as String?,
      imageProfile: json['imageProfile'] as String?,
    );
  }

  String get fullName {
    final n = name ?? '';
    final l = lastName ?? '';
    return '$n $l'.trim();
  }
}

class NotificationServiceRequest {
  final String? id;
  final String? description;
  final String? direction;
  final String? occupationName;

  const NotificationServiceRequest({
    this.id,
    this.description,
    this.direction,
    this.occupationName,
  });

  factory NotificationServiceRequest.fromJson(Map<String, dynamic> json) {
    return NotificationServiceRequest(
      id: json['id'] as String?,
      description: json['description'] as String?,
      direction: json['direction'] as String?,
      occupationName: json['occupationName'] as String?,
    );
  }
}

class NotificationColab {
  final String? id;
  final String? name;
  final String? lastName;
  final String? imageProfile;

  const NotificationColab({
    this.id,
    this.name,
    this.lastName,
    this.imageProfile,
  });

  factory NotificationColab.fromJson(Map<String, dynamic> json) {
    return NotificationColab(
      id: json['id'] as String?,
      name: json['name'] as String?,
      lastName: json['lastName'] as String?,
      imageProfile: json['imageProfile'] as String?,
    );
  }

  String get fullName {
    final n = name ?? '';
    final l = lastName ?? '';
    return '$n $l'.trim();
  }
}

class NotificationProposal {
  final double? amount;
  final double? distanceKm;
  final NotificationColab? colab;

  const NotificationProposal({
    this.amount,
    this.distanceKm,
    this.colab,
  });

  factory NotificationProposal.fromJson(Map<String, dynamic> json) {
    return NotificationProposal(
      amount: (json['amount'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      colab: json['colab'] != null
          ? NotificationColab.fromJson(json['colab'] as Map<String, dynamic>)
          : null,
    );
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String? body;
  final String? entityType;
  final String? entityId;
  final bool isRead;
  final String creationDate;
  final NotificationServiceRequest? serviceRequest;
  final NotificationRequester? requester;
  final NotificationProposal? proposal;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.body,
    this.entityType,
    this.entityId,
    required this.isRead,
    required this.creationDate,
    this.serviceRequest,
    this.requester,
    this.proposal,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      entityType: json['entityType'] as String?,
      entityId: json['entityId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      creationDate: json['creationDate'] as String,
      serviceRequest: json['serviceRequest'] != null
          ? NotificationServiceRequest.fromJson(
              json['serviceRequest'] as Map<String, dynamic>)
          : null,
      requester: json['requester'] != null
          ? NotificationRequester.fromJson(
              json['requester'] as Map<String, dynamic>)
          : null,
      proposal: json['proposal'] != null
          ? NotificationProposal.fromJson(
              json['proposal'] as Map<String, dynamic>)
          : null,
    );
  }
}
