import 'package:equatable/equatable.dart';
import '../models/post_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final List<PostModel> posts;
  final bool            hasMore;
  final int             currentPage;

  const HomeSuccess({
    required this.posts,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [posts, hasMore, currentPage];
}

class HomeLoadingMore extends HomeSuccess {
  const HomeLoadingMore({
    required super.posts,
    required super.hasMore,
    required super.currentPage,
  });
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}