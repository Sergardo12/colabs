import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../data/search_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

/// Debounce + restartable: espera 350ms sin escribir y cancela la anterior
EventTransformer<SearchQueryChanged> debounceRestartable(Duration duration) {
  return (events, mapper) =>
      restartable<SearchQueryChanged>().call(events.debounceTime(duration), mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepository;
  String? _currentQuery;
  CancelToken? _cancelToken;

  SearchBloc({required SearchRepository searchRepository})
      : _searchRepository = searchRepository,
        super(SearchInitial()) {
    on<SearchColabRequested>(_onSearchColabRequested);
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounceRestartable(const Duration(milliseconds: 350)),
    );
    on<SearchLoadMoreRequested>(_onSearchLoadMoreRequested);
    on<SearchCleared>(_onSearchCleared);
  }

  /// Búsqueda inicial o nueva búsqueda
  Future<void> _onSearchColabRequested(
  SearchColabRequested event,
  Emitter<SearchState> emit,
) async {
  emit(SearchLoading());
  _currentQuery = event.query;

  try {
    final response = await _searchRepository.searchColabs(
      query: event.query,
      page:  1,
    );

    if (response.data.isEmpty) {
      emit(SearchEmpty(query: event.query ?? ''));
      return;
    }

    emit(SearchSuccess(
      results:     response.data,
      hasMore:     response.page < response.lastPage,
      currentPage: response.page,
      query:       event.query,
    ));
  } catch (e) {
    emit(const SearchError(message: 'Error al buscar colaboradores'));
  }
}

  /// Búsqueda en tiempo real mientras se escribe (debounce 350ms)
  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    // Mínimo 2 caracteres para buscar en tiempo real
    if (query.length == 1) return;

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    // Al borrar el texto se devuelve la lista completa paginada
    if (query.isEmpty) {
      _currentQuery = null;
      emit(SearchLoading());
      try {
        final response = await _searchRepository.searchColabs(
          page: 1,
          cancelToken: _cancelToken,
        );
        if (response.data.isEmpty) {
          emit(SearchEmpty(query: ''));
          return;
        }
        emit(SearchSuccess(
          results:     response.data,
          hasMore:     response.page < response.lastPage,
          currentPage: response.page,
          query:       null,
        ));
      } catch (e) {
        emit(const SearchError(message: 'Error al buscar colaboradores'));
      }
      return;
    }

    if (query == _currentQuery) return;

    // Mantener resultados previos con overlay mientras filtra
    final prev = state;
    _currentQuery = query;

    if (prev is SearchSuccess && prev.results.isNotEmpty) {
      emit(SearchFiltering(
        results:     prev.results,
        hasMore:     prev.hasMore,
        currentPage: prev.currentPage,
        query:       prev.query,
      ));
    } else {
      emit(SearchLoading());
    }

    try {
      final response = await _searchRepository.searchColabs(
        query:  query,
        page:   1,
        cancelToken: _cancelToken,
      );

      if (response.data.isEmpty) {
        emit(SearchEmpty(query: query));
        return;
      }

      emit(SearchSuccess(
        results:     response.data,
        hasMore:     response.page < response.lastPage,
        currentPage: response.page,
        query:       query,
      ));
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        // Request cancelada por una nueva búsqueda — no emitir error
        return;
      }
      emit(SearchError(message: 'Error al buscar colaboradores'));
    }
  }

  /// Carga más resultados — infinite scroll
  Future<void> _onSearchLoadMoreRequested(
    SearchLoadMoreRequested event,
    Emitter<SearchState> emit,
  ) async {
    final current = state;
    if (current is SearchFiltering) return;
    if (current is! SearchSuccess || !current.hasMore) return;

    emit(SearchLoadingMore(
      results:     current.results,
      hasMore:     current.hasMore,
      currentPage: current.currentPage,
      query:       current.query,
    ));

    try {
      final nextPage = current.currentPage + 1;
      final response = await _searchRepository.searchColabs(
        query: _currentQuery,
        page:  nextPage,
        cancelToken: _cancelToken,
      );

      emit(SearchSuccess(
        results:     [...current.results, ...response.data],
        hasMore:     response.page < response.lastPage,
        currentPage: response.page,
        query:       current.query,
      ));
    } catch (e) {
      emit(SearchSuccess(
        results:     current.results,
        hasMore:     current.hasMore,
        currentPage: current.currentPage,
        query:       current.query,
      ));
    }
  }

  /// Limpia la búsqueda
  void _onSearchCleared(
    SearchCleared event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }
}