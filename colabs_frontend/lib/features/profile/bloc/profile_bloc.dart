import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
  }

  /// Carga el perfil del usuario autenticado
  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final result = await _profileRepository.getMyProfile();
      emit(ProfileSuccess(
        user:  result.user,
        colab: result.colab,
      ));
    } catch (e) {
      emit(const ProfileError(message: 'Error al cargar el perfil'));
    }
  }
}