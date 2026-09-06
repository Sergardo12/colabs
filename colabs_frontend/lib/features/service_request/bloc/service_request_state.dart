import 'package:equatable/equatable.dart';
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
  const ServiceRequestSuccess({required this.requests});
  @override
  List<Object?> get props => [requests];
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
