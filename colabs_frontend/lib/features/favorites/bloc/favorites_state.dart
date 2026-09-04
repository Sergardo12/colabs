import 'package:equatable/equatable.dart';
import '../../search/models/colab_search_model.dart';
import '../models/favorite_filter.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final Set<String> favoriteIds;
  final List<ColabSearchModel> favorites;
  final FavoriteFilterType activeFilter;

  const FavoritesLoaded({
    required this.favoriteIds,
    this.favorites = const [],
    this.activeFilter = FavoriteFilterType.workers,
  });

  bool isFavorite(String profileColabId) =>
      favoriteIds.contains(profileColabId);

  @override
  List<Object?> get props => [favoriteIds, favorites, activeFilter];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError({required this.message});

  @override
  List<Object?> get props => [message];
}
