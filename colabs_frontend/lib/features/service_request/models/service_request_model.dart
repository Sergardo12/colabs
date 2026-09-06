class ServiceRequestOccupation {
  final String  id;
  final String  name;
  final String? image;

  const ServiceRequestOccupation({
    required this.id,
    required this.name,
    this.image,
  });

  factory ServiceRequestOccupation.fromJson(Map<String, dynamic> json) {
    return ServiceRequestOccupation(
      id:    json['id']    as String? ?? '',
      name:  json['name']  as String? ?? '',
      image: json['image'] as String?,
    );
  }
}

class ServiceRequestRequester {
  final String? id;
  final String? name;
  final String? lastName;
  final String? imageProfile;

  const ServiceRequestRequester({
    this.id,
    this.name,
    this.lastName,
    this.imageProfile,
  });

  factory ServiceRequestRequester.fromJson(Map<String, dynamic> json) {
    return ServiceRequestRequester(
      id:           json['id']           as String?,
      name:         json['name']         as String?,
      lastName:     json['lastName']     as String?,
      imageProfile: json['imageProfile'] as String?,
    );
  }

  String get fullName => '${name ?? ''} ${lastName ?? ''}'.trim();
}

class ServiceRequestModel {
  final String                   id;
  final String                   status;
  final String                   direction;
  final String                   description;
  final String                   createdAt;
  final String?                  acceptanceDate;
  final String?                  completionDate;
  final double?                  distanceKm;
  final int?                     proposalsCount;
  final ServiceRequestOccupation occupation;
  final ServiceRequestRequester? requester;

  const ServiceRequestModel({
    required this.id,
    required this.status,
    required this.direction,
    required this.description,
    required this.createdAt,
    this.acceptanceDate,
    this.completionDate,
    this.distanceKm,
    this.proposalsCount,
    required this.occupation,
    this.requester,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id:             json['id']             as String,
      status:         json['status']         as String,
      direction:   json['direction']   as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt:      json['createdAt']      as String,
      acceptanceDate: json['acceptanceDate'] as String?,
      completionDate: json['completionDate'] as String?,
      distanceKm:     (json['distanceKm'] as num?)?.toDouble(),
      proposalsCount: (json['proposalsCount'] as num?)?.toInt(),
      occupation:     ServiceRequestOccupation.fromJson(
                        json['occupation'] as Map<String, dynamic>),
      requester:      json['user'] != null
                        ? ServiceRequestRequester.fromJson(
                            json['user'] as Map<String, dynamic>)
                        : null,
    );
  }
}
