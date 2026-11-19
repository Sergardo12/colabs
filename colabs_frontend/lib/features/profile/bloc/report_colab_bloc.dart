import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../service_request/data/service_request_repository.dart';
import '../data/support_repository.dart';
import 'report_colab_event.dart';
import 'report_colab_state.dart';

EventTransformer<ReportSearchChanged> _debounceRestartable(
  Duration duration,
) {
  return (events, mapper) => restartable<ReportSearchChanged>()
      .call(events.debounceTime(duration), mapper);
}

class ReportColabBloc extends Bloc<ReportColabEvent, ReportColabState> {
  final ServiceRequestRepository _serviceRequestRepository;
  final SupportRepository _supportRepository;

  String _currentQuery = '';
  int _requestId = 0;

  ReportColabBloc({
    required this._serviceRequestRepository,
    required this._supportRepository,
  }) : super(const ReportColabState()) {
    on<ReportCancelledServicesLoadRequested>(_onLoad);
    on<ReportSearchChanged>(
      _onSearch,
      transformer: _debounceRestartable(
        const Duration(milliseconds: 350),
      ),
    );
    on<ReportServiceSelected>(_onSelect);
    on<ReportSubmitRequested>(_onSubmit);
  }

  Future<void> _onLoad(
    ReportCancelledServicesLoadRequested event,
    Emitter<ReportColabState> emit,
  ) async {
    _currentQuery = '';
    final requestId = ++_requestId;

    emit(
      state.copyWith(
        status: ReportColabStatus.loading,
        query: '',
        clearSelected: true,
        clearError: true,
      ),
    );

    try {
      final services =
          await _serviceRequestRepository.getCancelledWithColab();

      if (requestId != _requestId) return;

      emit(
        state.copyWith(
          status: ReportColabStatus.loaded,
          services: services,
          query: '',
          clearSelected: true,
          clearError: true,
        ),
      );
    } catch (_) {
      if (requestId != _requestId) return;

      emit(
        state.copyWith(
          status: ReportColabStatus.failure,
          errorMessage: 'No se pudieron cargar los servicios',
        ),
      );
    }
  }

  Future<void> _onSearch(
    ReportSearchChanged event,
    Emitter<ReportColabState> emit,
  ) async {
    final query = event.query.trim();
    if (query == _currentQuery) return;

    _currentQuery = query;
    final requestId = ++_requestId;

    emit(
      state.copyWith(
        status: ReportColabStatus.loading,
        query: query,
        clearSelected: true,
        clearError: true,
      ),
    );

    try {
      final services = await _serviceRequestRepository.getCancelledWithColab(
        search: query.isEmpty ? null : query,
      );

      if (requestId != _requestId) return;

      emit(
        state.copyWith(
          status: ReportColabStatus.loaded,
          services: services,
          query: query,
          clearSelected: true,
          clearError: true,
        ),
      );
    } catch (_) {
      if (requestId != _requestId) return;

      emit(
        state.copyWith(
          status: ReportColabStatus.failure,
          errorMessage: 'No se pudieron buscar los servicios',
        ),
      );
    }
  }

  void _onSelect(
    ReportServiceSelected event,
    Emitter<ReportColabState> emit,
  ) {
    if (event.service == null) {
      emit(state.copyWith(clearSelected: true));
      return;
    }

    emit(state.copyWith(selected: event.service));
  }

  Future<void> _onSubmit(
    ReportSubmitRequested event,
    Emitter<ReportColabState> emit,
  ) async {
    final selected = state.selected;
    final description = event.description.trim();

    if (selected == null || description.isEmpty) return;

    emit(
      state.copyWith(
        status: ReportColabStatus.submitting,
        clearError: true,
      ),
    );

    try {
      await _supportRepository.createReport(
        profileColabId: selected.profileColabId,
        category: 'comportamiento_inapropiado',
        serviceRequestId: selected.id,
        description: description,
      );

      emit(
        state.copyWith(
          status: ReportColabStatus.submitted,
          clearError: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ReportColabStatus.failure,
          errorMessage: 'Error al enviar. Intenta de nuevo',
        ),
      );
    }
  }
}
