class ProposalColab {
  final String? userId;
  final String? name;
  final String? lastName;
  final String? imageProfile;
  final double averageRating;

  const ProposalColab({
    this.userId,
    this.name,
    this.lastName,
    this.imageProfile,
    this.averageRating = 0,
  });

  factory ProposalColab.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return ProposalColab(
      userId:       user?['id'] as String?,
      name:         user?['name'] as String?,
      lastName:     (user?['lastName'] ?? user?['last_name']) as String?,
      imageProfile: user?['imageProfile'] as String?,
      averageRating:
          (json['averageRating'] as num?)?.toDouble() ??
          (json['average_rating'] as num?)?.toDouble() ??
          0,
    );
  }

  String get fullName => '${name ?? ''} ${lastName ?? ''}'.trim();
}

class ProposalModel {
  final String  id;
  final String  serviceRequestId;
  final double  amount;
  final String  status;
  final ProposalColab colab;

  const ProposalModel({
    required this.id,
    required this.serviceRequestId,
    required this.amount,
    required this.status,
    required this.colab,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    return ProposalModel(
      id:                json['id'] as String,
      serviceRequestId:  json['serviceRequestId'] as String? ?? json['service_request_id'] as String? ?? '',
      amount:            _parseAmount(json['amount']),
      status:            (json['status'] as String?) ?? 'pending',
      colab: ProposalColab.fromJson(
        json['profileColab'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  static double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
