import 'package:equatable/equatable.dart';
import '../../profile/models/occupation_model.dart';

abstract class RequestMapState extends Equatable {
  const RequestMapState();

  @override
  List<Object?> get props => [];
}

class RequestMapInitial extends RequestMapState {}

class RequestMapOccupationsLoading extends RequestMapState {}

class RequestMapOccupationsLoaded extends RequestMapState {
  final List<OccupationItem> occupations;

  const RequestMapOccupationsLoaded({required this.occupations});

  @override
  List<Object?> get props => [occupations];
}

class RequestMapError extends RequestMapState {
  final String message;

  const RequestMapError({required this.message});

  @override
  List<Object?> get props => [message];
}
