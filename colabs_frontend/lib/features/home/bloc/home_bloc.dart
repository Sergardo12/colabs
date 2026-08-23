import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/home_repository.dart';
import '../models/post_model.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;

  /// Posts con toggle de like en curso — evita doble tap mientras responde el API
  final Set<String> _pendingLikeToggles = {};

  HomeBloc({required HomeRepository homeRepository})
      : _homeRepository = homeRepository,
        super(HomeInitial()) {
    on<FeedLoadRequested>(_onFeedLoadRequested);
    on<FeedLoadMoreRequested>(_onFeedLoadMoreRequested);
    on<FeedRefreshRequested>(_onFeedRefreshRequested);
    on<PostLikeToggled>(_onPostLikeToggled);
  }

  /// Carga inicial del feed
  Future<void> _onFeedLoadRequested(
    FeedLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final response = await _homeRepository.getFeed(page: 1);
      emit(HomeSuccess(
        posts:       response.data,
        hasMore:     response.page < response.lastPage,
        currentPage: response.page,
      ));
    } catch (e) {
      emit(HomeError(message: 'Error al cargar el feed'));
    }
  }

  /// Carga más posts — infinite scroll
  Future<void> _onFeedLoadMoreRequested(
    FeedLoadMoreRequested event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeSuccess || !current.hasMore) return;

    emit(HomeLoadingMore(
      posts:       current.posts,
      hasMore:     current.hasMore,
      currentPage: current.currentPage,
    ));

    try {
      final nextPage = current.currentPage + 1;
      final response = await _homeRepository.getFeed(page: nextPage);
      emit(HomeSuccess(
        posts:       [...current.posts, ...response.data],
        hasMore:     response.page < response.lastPage,
        currentPage: response.page,
      ));
    } catch (e) {
      emit(HomeSuccess(
        posts:       current.posts,
        hasMore:     current.hasMore,
        currentPage: current.currentPage,
      ));
    }
  }

  /// Refresh silencioso — re-obtiene las páginas ya cargadas sin spinner
  Future<void> _onFeedRefreshRequested(
    FeedRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeSuccess || current.posts.isEmpty) return;

    try {
      // Paralelo preservando el orden de páginas
      final responses = await Future.wait(
        List<int>.generate(
          current.currentPage,
          (i) => i + 1,
        ).map((p) => _homeRepository.getFeed(page: p)),
      );

      emit(HomeSuccess(
        posts:       responses.expand((r) => r.data).toList(),
        hasMore:     responses.last.page < responses.last.lastPage,
        currentPage: responses.last.page,
      ));
    } catch (e) {
      // Silencioso — ante fallo real se mantiene el estado actual
    }
  }

  /// Toggle optimista — actualiza el corazón al instante y revierte si falla
  Future<void> _onPostLikeToggled(
    PostLikeToggled event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeSuccess) return;
    if (_pendingLikeToggles.contains(event.postId)) return;

    final index = current.posts.indexWhere((p) => p.id == event.postId);
    if (index == -1) return;

    final target = current.posts[index];
    final wasLiked = target.isLiked;

    // Actualización optimista del post afectado
    final newPosts = List<PostModel>.from(current.posts);
    newPosts[index] = PostModel(
      id:             target.id,
      profileColabId: target.profileColabId,
      description:    target.description,
      price:          target.price,
      media:          target.media,
      likesCount:     wasLiked ? target.likesCount - 1 : target.likesCount + 1,
      commentsCount:  target.commentsCount,
      isLiked:        !wasLiked,
      createdAt:      target.createdAt,
      author:         target.author,
      occupation:     target.occupation,
    );

    emit(HomeSuccess(
      posts:       newPosts,
      hasMore:     current.hasMore,
      currentPage: current.currentPage,
    ));

    _pendingLikeToggles.add(event.postId);
    try {
      if (wasLiked) {
        await _homeRepository.unlikePost(event.postId);
      } else {
        await _homeRepository.likePost(event.postId);
      }
    } catch (e) {
      // Revierte el toggle optimista
      emit(HomeSuccess(
        posts:       current.posts,
        hasMore:     current.hasMore,
        currentPage: current.currentPage,
      ));
    } finally {
      _pendingLikeToggles.remove(event.postId);
    }
  }
}