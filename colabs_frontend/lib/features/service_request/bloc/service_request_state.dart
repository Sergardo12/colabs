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

class ServiceRequestError extends ServiceRequestState {
  final String message;
  const ServiceRequestError({required this.message});
  @override
  List<Object?> get props => [message];
}
