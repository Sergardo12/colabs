import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FeedLoadRequested extends HomeEvent {
  const FeedLoadRequested();
}

class FeedLoadMoreRequested extends HomeEvent {
  const FeedLoadMoreRequested();
}

/// Re-sincroniza el feed con el servidor sin mostrar spinner
class FeedRefreshRequested extends HomeEvent {
  const FeedRefreshRequested();
}

/// Alterna el like de un post en el feed
class PostLikeToggled extends HomeEvent {
  final String postId;

  const PostLikeToggled(this.postId);

  @override
  List<Object?> get props => [postId];
}