import 'package:equatable/equatable.dart';
import '../models/profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final UserProfileModel  user;
  final ColabProfileModel? colab;

  const ProfileSuccess({
    required this.user,
    this.colab,
  });

  @override
  List<Object?> get props => [user, colab];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}