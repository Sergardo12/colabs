import 'package:equatable/equatable.dart';
import '../../service_request/models/reportable_service_model.dart';

enum ReportColabStatus {
  initial,
  loading,
  loaded,
  submitting,
  submitted,
  alreadyReported,
  failure,
}

class ReportColabState extends Equatable {
  final ReportColabStatus status;
  final List<ReportableServiceModel> services;
  final String query;
  final ReportableServiceModel? selected;
  final String? errorMessage;

  const ReportColabState({
    this.status = ReportColabStatus.initial,
    this.services = const [],
    this.query = '',
    this.selected,
    this.errorMessage,
  });

  bool get isLoading => status == ReportColabStatus.loading;
  bool get isSubmitting => status == ReportColabStatus.submitting;

  ReportColabState copyWith({
    ReportColabStatus? status,
    List<ReportableServiceModel>? services,
    String? query,
    ReportableServiceModel? selected,
    bool clearSelected = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportColabState(
      status: status ?? this.status,
      services: services ?? this.services,
      query: query ?? this.query,
      selected: clearSelected ? null : (selected ?? this.selected),
      errorMessage:
          clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        services,
        query,
        selected,
        errorMessage,
      ];
}
