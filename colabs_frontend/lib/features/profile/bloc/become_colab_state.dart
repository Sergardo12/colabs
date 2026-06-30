import 'package:equatable/equatable.dart';
import '../models/occupation_model.dart';

abstract class BecomeColabState extends Equatable {
  const BecomeColabState();

  @override
  List<Object?> get props => [];
}

class BecomeColabInitial extends BecomeColabState {}

class OccupationsLoading extends BecomeColabState {}

class OccupationsLoaded extends BecomeColabState {
  final List<OccupationItem> occupations;

  const OccupationsLoaded({required this.occupations});

  @override
  List<Object?> get props => [occupations];
}

class OccupationsError extends BecomeColabState {
  final String message;

  const OccupationsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BecomeColabSubmitting extends BecomeColabState {}

class BecomeColabSuccess extends BecomeColabState {}

class BecomeColabError extends BecomeColabState {
  final String message;

  const BecomeColabError({required this.message});

  @override
  List<Object?> get props => [message];
}