import 'package:equatable/equatable.dart';
import '../models/proposal_model.dart';
import '../models/service_request_model.dart';

abstract class ServiceRequestState extends Equatable {
  const ServiceRequestState();
  @override
  List<Object?> get props => [];
}

class ServiceRequestInitial extends ServiceRequestState {}
class ServiceRequestLoading extends ServiceRequestState {}

class ServiceRequestSuccess extends ServiceRequestState {
  final List<ServiceRequestModel> requests;

  /// Ids de solicitudes ya calificadas por el demandante
  /// (cargados desde GET /comment-requests/my-reviews).
  final Set<String> ratedIds;

  const ServiceRequestSuccess({
    required this.requests,
    this.ratedIds = const {},
  });
  @override
  List<Object?> get props => [requests, ratedIds];
}

class ServiceRequestCreating extends ServiceRequestState {}

class ServiceRequestCreated extends ServiceRequestState {
  final ServiceRequestModel request;
  const ServiceRequestCreated({required this.request});
  @override
  List<Object?> get props => [request];
}

class ServiceRequestError extends ServiceRequestState {
  final String message;
  const ServiceRequestError({required this.message});
  @override
  List<Object?> get props => [message];
}

class NearbyRequestsLoading extends ServiceRequestState {}

class NearbyRequestsSuccess extends ServiceRequestState {
  final List<ServiceRequestModel> requests;
  const NearbyRequestsSuccess({required this.requests});
  @override
  List<Object?> get props => [requests];
}

class NearbyRequestsError extends ServiceRequestState {
  final String message;
  const NearbyRequestsError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ProposalSending extends ServiceRequestState {}

class ProposalSent extends ServiceRequestState {
  final String serviceRequestId;
  const ProposalSent({required this.serviceRequestId});
  @override
  List<Object?> get props => [serviceRequestId];
}

class ProposalSendError extends ServiceRequestState {
  final String message;
  const ProposalSendError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ProposalsLoading extends ServiceRequestState {}

class ProposalsLoaded extends ServiceRequestState {
  final List<ProposalModel> proposals;
  final String requestStatus;
  const ProposalsLoaded({
    required this.proposals,
    required this.requestStatus,
  });
  @override
  List<Object?> get props => [proposals, requestStatus];
}

class ProposalsError extends ServiceRequestState {
  final String message;
  const ProposalsError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ProposalAccepted extends ServiceRequestState {
  final String requestId;
  const ProposalAccepted({required this.requestId});
  @override
  List<Object?> get props => [requestId];
}

class ProposalActionError extends ServiceRequestState {
  final String message;
  const ProposalActionError({required this.message});
  @override
  List<Object?> get props => [message];
}

class StartWorkInProgress extends ServiceRequestState {}

class StartWorkSuccess extends ServiceRequestState {
  final String requestId;
  const StartWorkSuccess({required this.requestId});
  @override
  List<Object?> get props => [requestId];
}

class StartWorkError extends ServiceRequestState {
  final String message;
  const StartWorkError({required this.message});
  @override
  List<Object?> get props => [message];
}

class CompleteWorkInProgress extends ServiceRequestState {}

class CompleteWorkSuccess extends ServiceRequestState {
  final String requestId;
  const CompleteWorkSuccess({required this.requestId});
  @override
  List<Object?> get props => [requestId];
}

class CompleteWorkError extends ServiceRequestState {
  final String message;
  const CompleteWorkError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ReviewSubmitting extends ServiceRequestState {}

class ReviewSubmitted extends ServiceRequestState {
  final String serviceRequestId;
  const ReviewSubmitted({required this.serviceRequestId});
  @override
  List<Object?> get props => [serviceRequestId];
}

class ReviewSubmitError extends ServiceRequestState {
  final String message;
  const ReviewSubmitError({required this.message});
  @override
  List<Object?> get props => [message];
}
