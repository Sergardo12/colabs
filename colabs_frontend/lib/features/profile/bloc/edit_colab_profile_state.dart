import 'package:equatable/equatable.dart';
import '../models/profile_model.dart';
import '../models/occupation_model.dart';

abstract class EditColabProfileState extends Equatable {
  const EditColabProfileState();

  @override
  List<Object?> get props => [];
}

class EditColabProfileInitial extends EditColabProfileState {}

class EditColabProfileLoading extends EditColabProfileState {}

class EditColabProfileLoaded extends EditColabProfileState {
  final UserProfileModel user;
  final ColabProfileModel colab;
  final List<OccupationItem> availableOccupations;

  const EditColabProfileLoaded({
    required this.user,
    required this.colab,
    required this.availableOccupations,
  });

  @override
  List<Object?> get props => [user, colab, availableOccupations];
}

class EditColabProfileSubmitting extends EditColabProfileState {}

class EditColabProfileSuccess extends EditColabProfileState {}

class EditColabProfileError extends EditColabProfileState {
  final String message;

  const EditColabProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
