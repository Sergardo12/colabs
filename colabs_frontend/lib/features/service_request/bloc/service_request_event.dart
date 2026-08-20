import 'package:equatable/equatable.dart';

abstract class ServiceRequestEvent extends Equatable {
  const ServiceRequestEvent();
  @override
  List<Object?> get props => [];
}

class MyRequestsLoadRequested extends ServiceRequestEvent {
  const MyRequestsLoadRequested();
}
