import 'package:colabs_frontend/core/network/api_client.dart';
import 'package:colabs_frontend/features/profile/bloc/report_colab_bloc.dart';
import 'package:colabs_frontend/features/profile/bloc/report_colab_event.dart';
import 'package:colabs_frontend/features/profile/bloc/report_colab_state.dart';
import 'package:colabs_frontend/features/profile/data/support_repository.dart';
import 'package:colabs_frontend/features/profile/data/support_service.dart';
import 'package:colabs_frontend/features/service_request/data/service_request_repository.dart';
import 'package:colabs_frontend/features/service_request/data/service_request_service.dart';
import 'package:colabs_frontend/features/service_request/models/reportable_service_model.dart';
import 'package:colabs_frontend/features/service_request/models/service_request_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeServiceRequestRepository extends ServiceRequestRepository {
  _FakeServiceRequestRepository(this._services)
      : super(
          service: ServiceRequestService(ApiClient.create()),
          secureStorage: const FlutterSecureStorage(),
        );

  final List<ReportableServiceModel> _services;

  @override
  Future<List<ReportableServiceModel>> getCancelledWithColab({
    String? search,
  }) async {
    return _services;
  }
}

class _FakeSupportRepository extends SupportRepository {
  _FakeSupportRepository()
      : super(
          service: SupportService(ApiClient.create()),
          secureStorage: const FlutterSecureStorage(),
        );

  @override
  Future<void> createReport({
    required String category,
    String? reportedUserId,
    String? profileColabId,
    String? serviceRequestId,
    String? description,
  }) async {
    throw const ReportAlreadyReportedException();
  }
}

void main() {
  late ReportColabBloc bloc;

  final service = const ReportableServiceModel(
    id: 'sr-1',
    description: 'Prueba',
    profileColabId: 'pc-1',
    occupation: ServiceRequestOccupation(
      id: 'occ-1',
      name: 'Electricista',
    ),
  );

  setUp(() {
    bloc = ReportColabBloc(
      serviceRequestRepository: _FakeServiceRequestRepository([service]),
      supportRepository: _FakeSupportRepository(),
    );
  });

  tearDown(() => bloc.close());

  test('el 409 tipado quita el servicio, limpia selected y muestra mensaje',
      () async {
    bloc.add(const ReportCancelledServicesLoadRequested());
    await bloc.stream.firstWhere((s) => s.status == ReportColabStatus.loaded);

    bloc.add(ReportServiceSelected(service));
    await bloc.stream.firstWhere((s) => s.selected?.id == 'sr-1');

    bloc.add(const ReportSubmitRequested('motivo'));
    final state = await bloc.stream
        .firstWhere((s) => s.status == ReportColabStatus.alreadyReported);

    expect(state.services, isEmpty);
    expect(state.selected, isNull);
    expect(state.errorMessage, 'Este servicio ya fue reportado');
  });
}
