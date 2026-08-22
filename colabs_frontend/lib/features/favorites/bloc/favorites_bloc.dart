import 'package:flutter_bloc/flutter_bloc.dart';
import '../../search/models/colab_search_model.dart';
import '../data/favorite_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoriteRepository _repository;

  FavoritesBloc({required FavoriteRepository repository})
      : _repository = repository,
        super(FavoritesInitial()) {
    on<FavoritesLoadRequested>(_onLoadRequested);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadRequested(
    FavoritesLoadRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());

    try {
      final favorites = await _repository.getFavorites();

      emit(FavoritesLoaded(
        favoriteIds: favorites.map((c) => c.id).toSet(),
        favorites:   favorites,
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
      favoriteIds: newIds,
      favorites:   newFavorites,
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
}
