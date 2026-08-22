import 'package:equatable/equatable.dart';
import '../../search/models/colab_search_model.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Carga la lista de favoritos al iniciar sesión o entrar a la vista
class FavoritesLoadRequested extends FavoritesEvent {
  const FavoritesLoadRequested();
}

/// Agrega o quita un colaborador de favoritos
class ToggleFavorite extends FavoritesEvent {
  final String profileColabId;

  /// Datos del colaborador para inserción optimista en la lista de favoritos
  final ColabSearchModel? colab;

  const ToggleFavorite(this.profileColabId, {this.colab});

  @override
  List<Object?> get props => [profileColabId, colab];
}
