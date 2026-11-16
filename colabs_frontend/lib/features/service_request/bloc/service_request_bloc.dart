import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/service_request_repository.dart';
import '../models/service_request_model.dart';
import 'service_request_event.dart';
import 'service_request_state.dart';

class ServiceRequestBloc
    extends Bloc<ServiceRequestEvent, ServiceRequestState> {
  final ServiceRequestRepository _repository;
  List<ServiceRequestModel> _nearbyRequestsCache = const [];
  final Set<String> _pendingRejectedIds = {};

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
    on<StartWorkRequested>(_onStartWorkRequested);
    on<CompleteWorkRequested>(_onCompleteWorkRequested);
    on<SubmitReviewRequested>(_onSubmitReviewRequested);
    on<CancelServiceRequestRequested>(_onCancelServiceRequestRequested);
    on<ReloadServiceRequestRequested>(_onReloadServiceRequestRequested);
    on<NearbyRequestRejected>(_onNearbyRequestRejected);
  }

  Future<void> _onMyRequestsLoadRequested(
    MyRequestsLoadRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ServiceRequestLoading());
    try {
      final requests = await _repository.getMyRequests();
      // Ids ya calificados: si falla no debe romper la carga de la lista.
      var ratedIds = <String>{};
      try {
        ratedIds = await _repository.getRatedRequestIds();
      } catch (_) {
        ratedIds = <String>{};
      }
      emit(ServiceRequestSuccess(requests: requests, ratedIds: ratedIds));
    } catch (e) {
      emit(
        const ServiceRequestError(message: 'Error al cargar tus solicitudes'),
      );
    }
  }

  Future<void> _onNearbyRequestsLoadRequested(
    NearbyRequestsLoadRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(NearbyRequestsLoading());
    try {
      final requests = await _repository.getNearbyRequests();
      var hiddenIds = <String>{};
      try {
        hiddenIds = await _repository.getHiddenNearbyRequestIds();
      } catch (_) {
        hiddenIds = <String>{};
      }
      hiddenIds.addAll(_pendingRejectedIds);
      final visible = requests
          .where((request) => !hiddenIds.contains(request.id))
          .toList();
      _nearbyRequestsCache = List.unmodifiable(visible);
      emit(NearbyRequestsSuccess(requests: _nearbyRequestsCache));
    } catch (e) {
      emit(NearbyRequestsError(message: _nearbyErrorMessage(e)));
    }
  }

  void _onNearbyRequestsLocationUnavailable(
    NearbyRequestsLocationUnavailable event,
    Emitter<ServiceRequestState> emit,
  ) {
    emit(
      const NearbyRequestsError(
        message:
            'Activa la ubicación del dispositivo para ver solicitudes cercanas',
      ),
    );
  }

  String _nearbyErrorMessage(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          final message = data['message'];
          if (message is String && message.isNotEmpty) return message;
          if (message is List &&
              message.isNotEmpty &&
              message.first is String) {
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
        lat: event.lat,
        lng: event.lng,
        direction: event.direction,
        occupationId: event.occupationId,
        description: event.description,
        profileColabId: event.profileColabId,
      );
      emit(ServiceRequestCreated(request: request));
      add(const MyRequestsLoadRequested());
    } catch (e) {
      emit(const ServiceRequestError(message: 'Error al crear la solicitud'));
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
        amount: event.amount,
      );
      emit(ProposalSent(serviceRequestId: event.serviceRequestId));
    } catch (e) {
      emit(
        ProposalSendError(
          message: _apiErrorMessage(e, 'No se pudo enviar la propuesta'),
        ),
      );
    }
  }

  String _apiErrorMessage(Object error, String fallback) {
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
    return fallback;
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
      emit(ProposalsLoaded(proposals: proposals, requestStatus: requestStatus));
    } catch (e) {
      emit(
        const ProposalsError(message: 'No se pudieron cargar las propuestas'),
      );
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
      emit(
        ProposalActionError(
          message: _apiErrorMessage(e, 'No se pudo enviar la propuesta'),
        ),
      );
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
      emit(
        ProposalActionError(
          message: _apiErrorMessage(e, 'No se pudo enviar la propuesta'),
        ),
      );
    }
  }

  Future<void> _onStartWorkRequested(
    StartWorkRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(StartWorkInProgress());
    try {
      await _repository.startWork(event.serviceRequestId);
      emit(StartWorkSuccess(requestId: event.serviceRequestId));
      add(const NearbyRequestsLoadRequested());
    } catch (e) {
      emit(
        StartWorkError(
          message: _apiErrorMessage(e, 'No se pudo iniciar el trabajo'),
        ),
      );
    }
  }

  Future<void> _onCompleteWorkRequested(
    CompleteWorkRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(CompleteWorkInProgress());
    try {
      await _repository.completeWork(event.serviceRequestId);
      emit(CompleteWorkSuccess(requestId: event.serviceRequestId));
      // Refleja el cambio reactivamente en ambas vistas:
      // HEAD 4 (Solicitudes según tu especialidad) y
      // HEAD 3 (Mis solicitudes del demandante).
      add(const MyRequestsLoadRequested());
      add(const NearbyRequestsLoadRequested());
    } catch (e) {
      emit(
        CompleteWorkError(
          message: _apiErrorMessage(e, 'No se pudo completar el servicio'),
        ),
      );
    }
  }

  Future<void> _onSubmitReviewRequested(
    SubmitReviewRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ReviewSubmitting());
    try {
      await _repository.submitReview(
        serviceRequestId: event.serviceRequestId,
        rating: event.rating,
        comment: event.comment,
      );
      emit(ReviewSubmitted(serviceRequestId: event.serviceRequestId));
      // Recarga reactiva: el set de ratedIds oculta la estrella en la card.
      add(const MyRequestsLoadRequested());
    } catch (e) {
      emit(
        ReviewSubmitError(
          message: _apiErrorMessage(e, 'No se pudo enviar la calificación'),
        ),
      );
    }
  }

  Future<void> _onCancelServiceRequestRequested(
    CancelServiceRequestRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(CancelServiceRequestInProgress());
    try {
      await _repository.cancelRequest(event.serviceRequestId);
      emit(CancelServiceRequestSuccess(requestId: event.serviceRequestId));
      add(const MyRequestsLoadRequested());
      if (event.refreshNearby) {
        add(const NearbyRequestsLoadRequested());
      }
    } catch (e) {
      emit(
        CancelServiceRequestError(
          message: _apiErrorMessage(e, 'No se pudo cancelar el servicio'),
        ),
      );
    }
  }

  Future<void> _onReloadServiceRequestRequested(
    ReloadServiceRequestRequested event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ReloadServiceRequestInProgress());
    try {
      final request = await _repository.reloadRequest(event.serviceRequestId);
      emit(ReloadServiceRequestSuccess(request: request));
      add(const MyRequestsLoadRequested());
    } catch (e) {
      emit(
        ReloadServiceRequestError(
          message: _apiErrorMessage(e, 'No se pudo volver a abrir el servicio'),
        ),
      );
    }
  }

  Future<void> _onNearbyRequestRejected(
    NearbyRequestRejected event,
    Emitter<ServiceRequestState> emit,
  ) async {
    _pendingRejectedIds.add(event.requestId);
    final visible = _nearbyRequestsCache
        .where((request) => request.id != event.requestId)
        .toList();
    _nearbyRequestsCache = List.unmodifiable(visible);

    // Oculta la tarjeta de inmediato. El estado global del BLoC puede ser
    // ServiceRequestSuccess (HEAD 3) aunque la vista de especialidad siga
    // mostrando la última lista NearbyRequestsSuccess.
    emit(NearbyRequestsSuccess(requests: _nearbyRequestsCache));

    try {
      await _repository.hideNearbyRequest(event.requestId);
      _pendingRejectedIds.remove(event.requestId);
    } catch (_) {
      // Si falla la persistencia, se mantiene en memoria para que la tarjeta
      // siga oculta durante la sesión actual.
    }
  }
}
