import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/profile_repository.dart';
import 'edit_colab_profile_event.dart';
import 'edit_colab_profile_state.dart';

class EditColabProfileBloc
    extends Bloc<EditColabProfileEvent, EditColabProfileState> {
  final ProfileRepository _profileRepository;

  EditColabProfileBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(EditColabProfileInitial()) {
    on<EditColabProfileLoadRequested>(_onLoadRequested);
    on<EditColabProfileSubmitted>(_onSubmitted);
  }

  Future<void> _onLoadRequested(
    EditColabProfileLoadRequested event,
    Emitter<EditColabProfileState> emit,
  ) async {
    emit(EditColabProfileLoading());
    try {
      final result = await _profileRepository.getMyProfile();
      final occupations = await _profileRepository.getOccupations();

      if (result.colab == null) {
        emit(const EditColabProfileError(
          message: 'No tienes perfil de colaborador',
        ));
        return;
      }

      emit(EditColabProfileLoaded(
        user: result.user,
        colab: result.colab!,
        availableOccupations: occupations,
      ));
    } catch (e) {
      emit(const EditColabProfileError(
        message: 'Error al cargar el perfil',
      ));
    }
  }

  Future<void> _onSubmitted(
    EditColabProfileSubmitted event,
    Emitter<EditColabProfileState> emit,
  ) async {
    emit(EditColabProfileSubmitting());
    try {
      await _profileRepository.updateUserProfile(
        name:        event.name,
        lastName:    event.lastName,
        phoneNumber: event.phoneNumber,
        dateBirth:   event.dateBirth,
        gender:      event.gender,
      );

      await _profileRepository.updateColabProfile(
        description:    event.description,
        experience:     event.experience,
        occupationIds:  event.occupationIds,
        certifications: event.certifications,
      );

      emit(EditColabProfileSuccess());
    } catch (e) {
      emit(const EditColabProfileError(
        message: 'Error al actualizar el perfil. Intenta de nuevo',
      ));
    }
  }
}
