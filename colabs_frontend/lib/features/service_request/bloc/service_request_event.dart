import 'package:equatable/equatable.dart';

abstract class ServiceRequestEvent extends Equatable {
  const ServiceRequestEvent();
  @override
  List<Object?> get props => [];
}

class MyRequestsLoadRequested extends ServiceRequestEvent {
  const MyRequestsLoadRequested();
}

class NearbyRequestsLoadRequested extends ServiceRequestEvent {
  const NearbyRequestsLoadRequested();
}

class NearbyRequestsLocationUnavailable extends ServiceRequestEvent {
  const NearbyRequestsLocationUnavailable();
}

class CreateRequestRequested extends ServiceRequestEvent {
  final double  lat;
  final double  lng;
  final String  direction;
  final String  occupationId;
  final String  description;
  final String? profileColabId;

  const CreateRequestRequested({
    required this.lat,
    required this.lng,
    required this.direction,
    required this.occupationId,
    required this.description,
    this.profileColabId,
  });

  @override
  List<Object?> get props => [
    lat, lng, direction, occupationId, description, profileColabId
  ];
}

class ProposalSendRequested extends ServiceRequestEvent {
  final String serviceRequestId;
  final double amount;

  const ProposalSendRequested({
    required this.serviceRequestId,
    required this.amount,
  });

  @override
  List<Object?> get props => [serviceRequestId, amount];
}

class ProposalsLoadRequested extends ServiceRequestEvent {
  final String requestId;
  const ProposalsLoadRequested({required this.requestId});
  @override
  List<Object?> get props => [requestId];
}

class ProposalAcceptRequested extends ServiceRequestEvent {
  final String proposalId;
  final String requestId;
  const ProposalAcceptRequested({
    required this.proposalId,
    required this.requestId,
  });
  @override
  List<Object?> get props => [proposalId, requestId];
}

class ProposalRejectRequested extends ServiceRequestEvent {
  final String proposalId;
  final String requestId;
  const ProposalRejectRequested({
    required this.proposalId,
    required this.requestId,
  });
  @override
  List<Object?> get props => [proposalId, requestId];
}
