import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/models/post_model.dart';
import '../data/post_favorite_repository.dart';
import 'post_favorites_event.dart';
import 'post_favorites_state.dart';

class PostFavoritesBloc
    extends Bloc<PostFavoritesEvent, PostFavoritesState> {
  final PostFavoriteRepository _postFavoriteRepository;

  /// Posts con toggle en curso — evita doble tap mientras responde el API
  final Set<String> _pendingToggles = {};

  PostFavoritesBloc({required PostFavoriteRepository postFavoriteRepository})
      : _postFavoriteRepository = postFavoriteRepository,
        super(PostFavoritesInitial()) {
    on<PostFavoritesLoadRequested>(_onLoadRequested);
    on<PostFavoriteToggled>(_onToggle);
  }

  /// Carga los posts favoritos del usuario
  Future<void> _onLoadRequested(
    PostFavoritesLoadRequested event,
    Emitter<PostFavoritesState> emit,
  ) async {
    emit(PostFavoritesLoading());
    try {
      final response = await _postFavoriteRepository.getFavoritePosts();
      emit(PostFavoritesLoaded(posts: response.data));
    } catch (e) {
      emit(const PostFavoritesError(
        message: 'Error al cargar tus publicaciones favoritas',
      ));
    }
  }

  /// Unlike optimista — quita el post al instante y lo restaura si falla el API
  Future<void> _onToggle(
    PostFavoriteToggled event,
    Emitter<PostFavoritesState> emit,
  ) async {
    final current = state;
    if (current is! PostFavoritesLoaded) return;
    if (_pendingToggles.contains(event.postId)) return;

    final index = current.posts.indexWhere((p) => p.id == event.postId);
    if (index == -1) return;

    final removed = current.posts[index];

    // Actualización optimista — el post sale de la lista
    final newPosts = List<PostModel>.from(current.posts)..removeAt(index);
    emit(PostFavoritesLoaded(posts: newPosts));

    _pendingToggles.add(event.postId);
    try {
      await _postFavoriteRepository.removeLike(event.postId);
    } catch (e) {
      // Revierte — restaura el post en su posición original
      final s = state;
      if (s is PostFavoritesLoaded) {
        final restored = List<PostModel>.from(s.posts);
        restored.insert(
          index >= restored.length ? restored.length : index,
          removed,
        );
        emit(PostFavoritesLoaded(posts: restored));
      }
    } finally {
      _pendingToggles.remove(event.postId);
    }
  }
}
