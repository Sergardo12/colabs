import 'package:equatable/equatable.dart';
import '../../service_request/models/reportable_service_model.dart';

abstract class ReportColabEvent extends Equatable {
  const ReportColabEvent();

  @override
  List<Object?> get props => [];
}

class ReportCancelledServicesLoadRequested extends ReportColabEvent {
  const ReportCancelledServicesLoadRequested();
}

class ReportSearchChanged extends ReportColabEvent {
  final String query;

  const ReportSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ReportServiceSelected extends ReportColabEvent {
  final ReportableServiceModel? service;

  const ReportServiceSelected(this.service);

  @override
  List<Object?> get props => [service?.id];
}

class ReportSubmitRequested extends ReportColabEvent {
  final String description;

  const ReportSubmitRequested(this.description);

  @override
  List<Object?> get props => [description];
}
