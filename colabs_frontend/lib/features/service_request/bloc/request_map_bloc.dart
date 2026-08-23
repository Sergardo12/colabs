import 'package:flutter_bloc/flutter_bloc.dart';
import '../../profile/data/become_colab_repository.dart';
import 'request_map_event.dart';
import 'request_map_state.dart';

class RequestMapBloc extends Bloc<RequestMapEvent, RequestMapState> {
  final BecomeColabRepository _repository;

  RequestMapBloc({required BecomeColabRepository repository})
      : _repository = repository,
        super(RequestMapInitial()) {
    on<OccupationsLoadRequested>(_onOccupationsLoadRequested);
  }

  Future<void> _onOccupationsLoadRequested(
    OccupationsLoadRequested event,
    Emitter<RequestMapState> emit,
  ) async {
    emit(RequestMapOccupationsLoading());

    try {
      final occupations = await _repository.getOccupations();
      emit(RequestMapOccupationsLoaded(occupations: occupations));
    } catch (e) {
      emit(const RequestMapError(message: 'Error al cargar ocupaciones'));
    }
  }
}
