import 'package:equatable/equatable.dart';
import '../../home/models/post_model.dart';
import '../models/public_colab_model.dart';
import '../models/review_model.dart';

abstract class PublicProfileState extends Equatable {
  const PublicProfileState();

  @override
  List<Object?> get props => [];
}

class PublicProfileInitial extends PublicProfileState {}

class PublicProfileLoading extends PublicProfileState {}

class PublicProfileSuccess extends PublicProfileState {
  final PublicColabModel  profile;
  final PublicProfileStats stats;
  final List<PostModel>    posts;
  final List<ReviewModel>  reviews;

  const PublicProfileSuccess({
    required this.profile,
    required this.stats,
    this.posts = const [],
    this.reviews = const [],
  });

  @override
  List<Object?> get props => [profile, stats, posts, reviews];
}

class PublicProfileError extends PublicProfileState {
  final String message;

  const PublicProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
