import 'proposal_model.dart';

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

class ServiceRequestProposal {
  final String      id;
  final String      status;
  final String      amount;
  final String      profileColabId;
  final ProposalColab colab;

  const ServiceRequestProposal({
    required this.id,
    required this.status,
    required this.amount,
    required this.profileColabId,
    required this.colab,
  });

  factory ServiceRequestProposal.fromJson(Map<String, dynamic> json) {
    final profileColab = json['profileColab'] as Map<String, dynamic>;
    return ServiceRequestProposal(
      id:             json['id']             as String,
      status:         json['status']         as String,
      amount:         json['amount']         as String,
      profileColabId: json['profileColabId'] as String,
      colab:          ProposalColab.fromJson(profileColab),
    );
  }
}

class ServiceRequestModel {
  final String                        id;
  final String                        status;
  final String                        direction;
  final String                        description;
  final String                        createdAt;
  final String?                       acceptanceDate;
  final String?                       completionDate;
  final double?                       distanceKm;
  final int?                          proposalsCount;
  final ServiceRequestOccupation      occupation;
  final ServiceRequestRequester?      requester;
  final List<ServiceRequestProposal>  proposals;
  final Map<String, dynamic>?         location;

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
    required this.proposals,
    this.location,
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
      proposals:      json['proposals'] != null
          ? (json['proposals'] as List<dynamic>)
              .map((e) => ServiceRequestProposal.fromJson(
                    e as Map<String, dynamic>))
              .toList()
          : [],
      location:       json['location'] as Map<String, dynamic>?,
    );
  }

  /// Retorna el colaborador aceptado (primera propuesta aceptada)
  ServiceRequestProposal? get acceptedProposal {
    try {
      return proposals.firstWhere((p) => p.status == 'accepted');
    } catch (_) {
      return null;
    }
  }
}