import 'package:equatable/equatable.dart';

abstract class PublicProfileEvent extends Equatable {
  const PublicProfileEvent();

  @override
  List<Object?> get props => [];
}

class PublicProfileLoadRequested extends PublicProfileEvent {
  final String userId;

  const PublicProfileLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}
