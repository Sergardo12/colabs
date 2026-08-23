import 'package:equatable/equatable.dart';

abstract class PostFavoritesEvent extends Equatable {
  const PostFavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Carga los posts likeados por el usuario
class PostFavoritesLoadRequested extends PostFavoritesEvent {
  const PostFavoritesLoadRequested();
}

/// Quita el like de un post en la lista de favoritos
class PostFavoriteToggled extends PostFavoritesEvent {
  final String postId;

  const PostFavoriteToggled(this.postId);

  @override
  List<Object?> get props => [postId];
}
