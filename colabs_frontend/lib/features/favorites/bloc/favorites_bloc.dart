import 'package:flutter_bloc/flutter_bloc.dart';
import '../../search/models/colab_search_model.dart';
import '../data/favorite_repository.dart';
import '../models/favorite_filter.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoriteRepository _repository;

  FavoritesBloc({required FavoriteRepository repository})
      : _repository = repository,
        super(FavoritesInitial()) {
    on<FavoritesLoadRequested>(_onLoadRequested);
    on<ToggleFavorite>(_onToggleFavorite);
    on<FavoriteFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
    FavoritesLoadRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    // Preserva el filtro activo — la carga se re-dispacha al re-entrar al tab
    final previousFilter = state is FavoritesLoaded
        ? (state as FavoritesLoaded).activeFilter
        : FavoriteFilterType.workers;

    emit(FavoritesLoading());

    try {
      final favorites = await _repository.getFavorites();

      emit(FavoritesLoaded(
        favoriteIds:  favorites.map((c) => c.id).toSet(),
        favorites:    favorites,
        activeFilter: previousFilter,
      ));
    } catch (e) {
      emit(const FavoritesError(message: 'Error al cargar favoritos'));
    }
  }

  /// Toggle optimista — actualiza la UI al instante y revierte si falla
  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final current = state;
    if (current is! FavoritesLoaded) return;

    final wasFavorite = current.favoriteIds.contains(event.profileColabId);

    final newIds = Set<String>.from(current.favoriteIds);
    final newFavorites =
        List<ColabSearchModel>.from(current.favorites);

    if (wasFavorite) {
      newIds.remove(event.profileColabId);
      newFavorites.removeWhere((c) => c.id == event.profileColabId);
    } else {
      newIds.add(event.profileColabId);
      // Inserción en posición 0 — coincide con el orden createdAt DESC del backend
      if (event.colab != null) {
        newFavorites.insert(0, event.colab!);
      }
    }

    final newState = FavoritesLoaded(
      favoriteIds:  newIds,
      favorites:    newFavorites,
      activeFilter: current.activeFilter,
    );
    emit(newState);

    try {
      if (wasFavorite) {
        await _repository.removeFavorite(event.profileColabId);
      } else {
        await _repository.addFavorite(event.profileColabId);
      }
    } catch (e) {
      emit(current);
    }
  }

  /// Solo cambia el filtro — sin llamada HTTP
  Future<void> _onFilterChanged(
    FavoriteFilterChanged event,
    Emitter<FavoritesState> emit,
  ) async {
    final current = state;
    if (current is! FavoritesLoaded) return;

    emit(FavoritesLoaded(
      favoriteIds:  current.favoriteIds,
      favorites:    current.favorites,
      activeFilter: event.filter,
    ));
  }
}
