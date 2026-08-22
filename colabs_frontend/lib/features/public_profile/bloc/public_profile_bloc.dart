import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/public_profile_repository.dart';
import '../models/public_colab_model.dart';
import 'public_profile_event.dart';
import 'public_profile_state.dart';

class PublicProfileBloc extends Bloc<PublicProfileEvent, PublicProfileState> {
  final PublicProfileRepository _repository;

  PublicProfileBloc({required PublicProfileRepository repository})
      : _repository = repository,
        super(PublicProfileInitial()) {
    on<PublicProfileLoadRequested>(_onLoadRequested);
  }

  /// Carga el perfil público: header + posts + reseñas
  Future<void> _onLoadRequested(
    PublicProfileLoadRequested event,
    Emitter<PublicProfileState> emit,
  ) async {
    emit(PublicProfileLoading());
    try {
      final profile = await _repository.getPublicColabProfile(
        userId: event.userId,
      );

      // Demandante sin perfil de colaborador → sin stats ni contenido
      if (!profile.isCollaborator) {
        emit(PublicProfileSuccess(
          profile: profile,
          stats:   const PublicProfileStats(),
        ));
        return;
      }

      final colabId = profile.colabId!;
      final (posts, reviews) = await (
        _repository.getProfilePosts(profileColabId: colabId),
        _repository.getProfileReviews(profileColabId: colabId),
      ).wait;

      final stats = PublicProfileStats(
        postCount:     posts.total,
        totalLikes:    posts.data.fold(0, (sum, post) => sum + post.likesCount),
        averageRating: reviews.averageRating,
        totalReviews:  reviews.totalReviews,
      );

      emit(PublicProfileSuccess(
        profile: profile,
        stats:   stats,
        posts:   posts.data,
        reviews: reviews.comments,
      ));
    } catch (e, stackTrace) {
      print('ERROR PUBLIC PROFILE: $e');
      print(stackTrace);
      emit(const PublicProfileError(
        message: 'Error al cargar el perfil público',
      ));
    }
  }
}
