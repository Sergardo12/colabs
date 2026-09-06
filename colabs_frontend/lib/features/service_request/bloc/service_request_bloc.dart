import 'package:dio/dio.dart';
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
    on<NearbyRequestsLoadRequested>(_onNearbyRequestsLoadRequested);
    on<NearbyRequestsLocationUnavailable>(_onNearbyRequestsLocationUnavailable);
    on<CreateRequestRequested>(_onCreateRequestRequested);
    on<ProposalSendRequested>(_onProposalSendRequested);
    on<ProposalsLoadRequested>(_onProposalsLoadRequested);
    on<ProposalAcceptRequested>(_onProposalAcceptRequested);
    on<ProposalRejectRequested>(_onProposalRejectRequested);
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

  Future<void> _onNearbyRequestsLoadRequested(
    NearbyRequestsLoadRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(NearbyRequestsLoading());
    try {
      final requests = await _repository.getNearbyRequests();
      emit(NearbyRequestsSuccess(requests: requests));
    } catch (e) {
      emit(NearbyRequestsError(message: _nearbyErrorMessage(e)));
    }
  }

  void _onNearbyRequestsLocationUnavailable(
    NearbyRequestsLocationUnavailable event,
    Emitter<ServiceRequestState> emit,
  ) {
    emit(const NearbyRequestsError(
      message:
          'Activa la ubicación del dispositivo para ver solicitudes cercanas'));
  }

  String _nearbyErrorMessage(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          final message = data['message'];
          if (message is String && message.isNotEmpty) return message;
          if (message is List && message.isNotEmpty && message.first is String) {
            return message.first as String;
          }
        }
        final statusMessage = error.response?.statusMessage;
        if (statusMessage != null && statusMessage.isNotEmpty) {
          return statusMessage;
        }
      }
    }
    return 'No se pudieron cargar las solicitudes cercanas';
  }

  Future<void> _onCreateRequestRequested(
    CreateRequestRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ServiceRequestCreating());
    try {
      final request = await _repository.createRequest(
        lat:          event.lat,
        lng:          event.lng,
        direction:    event.direction,
        occupationId: event.occupationId,
        description:  event.description,
      );
      emit(ServiceRequestCreated(request: request));
      add(const MyRequestsLoadRequested());
    } catch (e) {
      emit(const ServiceRequestError(
        message: 'Error al crear la solicitud'));
    }
  }

  Future<void> _onProposalSendRequested(
    ProposalSendRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ProposalSending());
    try {
      await _repository.sendProposal(
        serviceRequestId: event.serviceRequestId,
        amount:           event.amount,
      );
      emit(ProposalSent(serviceRequestId: event.serviceRequestId));
    } catch (e) {
      emit(ProposalSendError(message: _proposalErrorMessage(e)));
    }
  }

  String _proposalErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) return message;
        if (message is List && message.isNotEmpty && message.first is String) {
          return message.first as String;
        }
      }
      final statusMessage = error.response?.statusMessage;
      if (statusMessage != null && statusMessage.isNotEmpty) {
        return statusMessage;
      }
    }
    return 'No se pudo enviar la propuesta';
  }

  Future<void> _onProposalsLoadRequested(
    ProposalsLoadRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ProposalsLoading());
    try {
      final proposals = await _repository.getProposals(event.requestId);
      var requestStatus = 'pending';
      if (event.requestId.isNotEmpty) {
        try {
          final requests = await _repository.getMyRequests();
          requestStatus = requests
              .firstWhere((r) => r.id == event.requestId)
              .status;
        } catch (_) {
          // Lista de solicitudes no disponible; se asume pending.
        }
      }
      emit(ProposalsLoaded(
        proposals:    proposals,
        requestStatus: requestStatus,
      ));
    } catch (e) {
      emit(const ProposalsError(
        message: 'No se pudieron cargar las propuestas'));
    }
  }

  Future<void> _onProposalAcceptRequested(
    ProposalAcceptRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    try {
      await _repository.acceptProposal(event.proposalId);
      emit(ProposalAccepted(requestId: event.requestId));
      add(const MyRequestsLoadRequested());
      add(ProposalsLoadRequested(requestId: event.requestId));
    } catch (e) {
      emit(ProposalActionError(message: _proposalErrorMessage(e)));
    }
  }

  Future<void> _onProposalRejectRequested(
    ProposalRejectRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    try {
      await _repository.rejectProposal(event.proposalId);
      add(ProposalsLoadRequested(requestId: event.requestId));
      add(const MyRequestsLoadRequested());
    } catch (e) {
      emit(ProposalActionError(message: _proposalErrorMessage(e)));
    }
  }
}
