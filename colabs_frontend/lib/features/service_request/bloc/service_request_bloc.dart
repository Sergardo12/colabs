import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/service_request_repository.dart';
import 'service_request_event.dart';
import 'service_request_state.dart';

class ServiceRequestBloc extends Bloc<ServiceRequestEvent, ServiceRequestState> {
  final ServiceRequestRepository _repository;

  ServiceRequestBloc({required ServiceRequestRepository repository})
      : _repository = repository,
        super(ServiceRequestInitial()) {
    on<MyRequestsLoadRequested>(_onMyRequestsLoadRequested);
  }

  Future<void> _onMyRequestsLoadRequested(
    MyRequestsLoadRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ServiceRequestLoading());
    try {
      final requests = await _repository.getMyRequests();
      emit(ServiceRequestSuccess(requests: requests));
    } catch (e) {
      emit(const ServiceRequestError(
        message: 'Error al cargar tus solicitudes'));
    }
  }
}
