import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;

  HomeBloc({required HomeRepository homeRepository})
      : _homeRepository = homeRepository,
        super(HomeInitial()) {
    on<FeedLoadRequested>(_onFeedLoadRequested);
    on<FeedLoadMoreRequested>(_onFeedLoadMoreRequested);
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
}