import 'service_request_model.dart';

class ReportableServiceModel {
  final String id;
  final String description;
  final String profileColabId;
  final ServiceRequestOccupation occupation;

  const ReportableServiceModel({
    required this.id,
    required this.description,
    required this.profileColabId,
    required this.occupation,
  });

  factory ReportableServiceModel.fromJson(Map<String, dynamic> json) {
    return ReportableServiceModel(
      id: json['id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      profileColabId: json['profileColabId'] as String? ?? '',
      occupation: ServiceRequestOccupation.fromJson(
        json['occupation'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
    );
  }
}
