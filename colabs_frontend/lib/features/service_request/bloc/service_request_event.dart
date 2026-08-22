import 'package:equatable/equatable.dart';

abstract class ServiceRequestEvent extends Equatable {
  const ServiceRequestEvent();
  @override
  List<Object?> get props => [];
}

class MyRequestsLoadRequested extends ServiceRequestEvent {
  const MyRequestsLoadRequested();
}

class CreateRequestRequested extends ServiceRequestEvent {
  final double lat;
  final double lng;
  final String direction;
  final String occupationId;
  final String description;

  const CreateRequestRequested({
    required this.lat,
    required this.lng,
    required this.direction,
    required this.occupationId,
    required this.description,
  });

  @override
  List<Object?> get props => [lat, lng, direction, occupationId, description];
}
