import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/become_colab_repository.dart';
import 'become_colab_event.dart';
import 'become_colab_state.dart';

class BecomeColabBloc extends Bloc<BecomeColabEvent, BecomeColabState> {
  final BecomeColabRepository _repository;

  BecomeColabBloc({required BecomeColabRepository repository})
      : _repository = repository,
        super(BecomeColabInitial()) {
    on<OccupationsLoadRequested>(_onOccupationsLoadRequested);
    on<BecomeColabSubmitted>(_onBecomeColabSubmitted);
  }

  /// Carga el catálogo de ocupaciones
  Future<void> _onOccupationsLoadRequested(
    OccupationsLoadRequested event,
    Emitter<BecomeColabState> emit,
  ) async {
    emit(OccupationsLoading());
    try {
      final occupations = await _repository.getOccupations();
      emit(OccupationsLoaded(occupations: occupations));
    } catch (e) {
      emit(const OccupationsError(message: 'Error al cargar ocupaciones'));
    }
  }

  /// Envía el formulario para convertirse en colaborador
  Future<void> _onBecomeColabSubmitted(
    BecomeColabSubmitted event,
    Emitter<BecomeColabState> emit,
  ) async {
    emit(BecomeColabSubmitting());
    try {
      await _repository.becomeColab(
        description:    event.description,
        experience:     event.experience,
        dni:            event.dni,
        occupationIds:  event.occupationIds,
        certifications: event.certifications,
      );
      emit(BecomeColabSuccess());
    } catch (e) {
      emit(const BecomeColabError(
        message: 'Error al procesar tu solicitud. Intenta de nuevo',
      ));
    }
  }
}