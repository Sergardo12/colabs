import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/search_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepository;
  String? _currentName;
  String? _currentOccupation;

  SearchBloc({required SearchRepository searchRepository})
      : _searchRepository = searchRepository,
        super(SearchInitial()) {
    on<SearchColabRequested>(_onSearchColabRequested);
    on<SearchLoadMoreRequested>(_onSearchLoadMoreRequested);
    on<SearchCleared>(_onSearchCleared);
  }

  /// Búsqueda inicial o nueva búsqueda
  Future<void> _onSearchColabRequested(
    SearchColabRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    _currentName       = event.name;
    _currentOccupation = event.occupation;

    try {
      final response = await _searchRepository.searchColabs(
        name:       event.name,
        occupation: event.occupation,
        page:       1,
      );

      if (response.data.isEmpty) {
        emit(SearchEmpty(query: event.name ?? event.occupation ?? ''));
        return;
      }

      emit(SearchSuccess(
        results:     response.data,
        hasMore:     response.page < response.lastPage,
        currentPage: response.page,
        query:       event.name ?? event.occupation,
      ));
    } catch (e) {
      emit(const SearchError(message: 'Error al buscar colaboradores'));
    }
  }

  /// Carga más resultados — infinite scroll
  Future<void> _onSearchLoadMoreRequested(
    SearchLoadMoreRequested event,
    Emitter<SearchState> emit,
  ) async {
    final current = state;
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
        name:       _currentName,
        occupation: _currentOccupation,
        page:       nextPage,
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
    _currentName       = null;
    _currentOccupation = null;
    emit(SearchInitial());
  }
}