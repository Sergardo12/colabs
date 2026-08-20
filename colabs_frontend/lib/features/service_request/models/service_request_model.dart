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
      id:    json['id']    as String,
      name:  json['name']  as String,
      image: json['image'] as String?,
    );
  }
}

class ServiceRequestModel {
  final String                  id;
  final String                  status;
  final String                  direction;
  final String                  description;
  final String                  createdAt;
  final String?                 acceptanceDate;
  final String?                 completionDate;
  final ServiceRequestOccupation occupation;

  const ServiceRequestModel({
    required this.id,
    required this.status,
    required this.direction,
    required this.description,
    required this.createdAt,
    this.acceptanceDate,
    this.completionDate,
    required this.occupation,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id:             json['id']             as String,
      status:         json['status']         as String,
      direction:      json['direction']      as String,
      description:    json['description']    as String,
      createdAt:      json['createdAt']      as String,
      acceptanceDate: json['acceptanceDate'] as String?,
      completionDate: json['completionDate'] as String?,
      occupation:     ServiceRequestOccupation.fromJson(
                        json['occupation'] as Map<String, dynamic>),
    );
  }
}
