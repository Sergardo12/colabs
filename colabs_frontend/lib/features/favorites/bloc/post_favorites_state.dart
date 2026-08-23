import 'package:equatable/equatable.dart';
import '../../home/models/post_model.dart';

abstract class PostFavoritesState extends Equatable {
  const PostFavoritesState();

  @override
  List<Object?> get props => [];
}

class PostFavoritesInitial extends PostFavoritesState {}

class PostFavoritesLoading extends PostFavoritesState {}

class PostFavoritesError extends PostFavoritesState {
  final String message;

  const PostFavoritesError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PostFavoritesLoaded extends PostFavoritesState {
  final List<PostModel> posts;

  const PostFavoritesLoaded({required this.posts});

  @override
  List<Object?> get props => [posts];
}
