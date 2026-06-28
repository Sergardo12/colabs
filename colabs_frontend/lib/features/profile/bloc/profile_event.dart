import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class PublicProfileLoadRequested extends ProfileEvent {
  final String userId;

  const PublicProfileLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}