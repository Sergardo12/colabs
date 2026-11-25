import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colabs_frontend/core/constants/app_strings.dart';
import 'package:colabs_frontend/features/statistics/bloc/statistics_bloc.dart';
import 'package:colabs_frontend/features/statistics/bloc/statistics_event.dart';
import 'package:colabs_frontend/features/statistics/bloc/statistics_state.dart';
import 'package:colabs_frontend/features/statistics/data/statistics_repository.dart';
import 'package:colabs_frontend/features/statistics/models/bar_datum.dart';
import 'package:colabs_frontend/features/statistics/models/monthly_goal.dart';
import 'package:colabs_frontend/features/statistics/models/services_offered_response.dart';
import 'package:colabs_frontend/features/statistics/models/services_rate.dart';
import 'package:colabs_frontend/features/statistics/models/statistics_data.dart';
import 'package:colabs_frontend/features/statistics/models/statistics_period.dart';

class FakeStatisticsRepository implements StatisticsRepository {
  FakeStatisticsRepository({
    required this.data,
    this.failOn,
    this.failSave = false,
  });

  final StatisticsData data;
  final StatisticsPeriod? failOn;
  final bool failSave;
  MonthlyGoal? replacementGoal;
  int? savedAmount;
  int rateCalls = 0;
  int ratingCalls = 0;
  int goalCalls = 0;

  @override
  Future<ServicesOfferedResponse> getServicesOffered(StatisticsPeriod period) async {
    if (failOn == period) throw Exception('falló');
    return ServicesOfferedResponse(
      period: period,
      accountCreatedYear: data.accountCreatedYear,
      bars: data.bars,
    );
  }

  @override
  Future<int> getServicesTotal(StatisticsPeriod period) async => data.totalServices;

  @override
  Future<ServicesRate> getServicesRate() async {
    rateCalls++;
    return data.rate;
  }

  @override
  Future<double?> getAverageRating() async {
    ratingCalls++;
    return data.averageRating;
  }

  @override
  Future<MonthlyGoal?> getMonthlyGoal() async {
    goalCalls++;
    return data.monthlyGoal;
  }

  @override
  Future<MonthlyGoal> saveMonthlyGoal(int amount) async {
    savedAmount = amount;
    if (failSave) throw Exception('falló');
    final now = DateTime.now();
    replacementGoal = MonthlyGoal(
      amount: amount,
      month: now.month,
      year: now.year,
      offered: data.monthlyOffered,
    );
    return replacementGoal!;
  }
}

class ControlledStatisticsRepository implements StatisticsRepository {
  final Map<StatisticsPeriod, Completer<ServicesOfferedResponse>> _offered =
      <StatisticsPeriod, Completer<ServicesOfferedResponse>>{};
  final Map<StatisticsPeriod, Completer<int>> _total =
      <StatisticsPeriod, Completer<int>>{};

  @override
  Future<ServicesOfferedResponse> getServicesOffered(StatisticsPeriod period) {
    final completer = Completer<ServicesOfferedResponse>();
    _offered[period] = completer;
    return completer.future;
  }

  @override
  Future<int> getServicesTotal(StatisticsPeriod period) {
    final completer = Completer<int>();
    _total[period] = completer;
    return completer.future;
  }

  @override
  Future<ServicesRate> getServicesRate() async => ServicesRate.empty;

  @override
  Future<double?> getAverageRating() async => null;

  @override
  Future<MonthlyGoal?> getMonthlyGoal() async => null;

  @override
  Future<MonthlyGoal> saveMonthlyGoal(int amount) async =>
      MonthlyGoal(amount: amount, month: 1, year: 2026);

  void complete(StatisticsPeriod period, StatisticsData data) {
    _offered[period]!.complete(
      ServicesOfferedResponse(
        period: period,
        accountCreatedYear: data.accountCreatedYear,
        bars: data.bars,
      ),
    );
    _total[period]!.complete(data.totalServices);
  }
}

StatisticsData _data() {
  final now = DateTime.now();
  return StatisticsData(
    period: StatisticsPeriod.days,
    bars: const [BarDatum(key: 1, value: 12)],
    rate: const ServicesRate(requested: 3, offered: 42),
    averageRating: 4.7,
    totalServices: 42,
    monthlyOffered: 28,
    accountCreatedYear: 2026,
    monthlyGoal: MonthlyGoal(
      amount: 70,
      month: now.month,
      year: now.year,
      offered: 28,
    ),
  );
}

void main() {
  late FakeStatisticsRepository repository;
  late ControlledStatisticsRepository controlled;

  setUp(() {
    repository = FakeStatisticsRepository(data: _data());
    controlled = ControlledStatisticsRepository();
  });

  group('StatisticsBloc', () {
    blocTest<StatisticsBloc, StatisticsState>(
      'carga datos iniciales en paralelo',
      build: () => StatisticsBloc(repository: repository),
      act: (bloc) => bloc.add(const StatisticsLoadRequested()),
      expect: () => [
        const StatisticsLoading(),
        StatisticsLoaded(data: _data(), period: StatisticsPeriod.days),
      ],
      verify: (_) {
        expect(repository.rateCalls, 1);
        expect(repository.ratingCalls, 1);
        expect(repository.goalCalls, 1);
      },
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'cambia el período y solo recarga barras y total',
      build: () => StatisticsBloc(repository: repository),
      seed: () => StatisticsLoaded(
        data: _data(),
        period: StatisticsPeriod.days,
      ),
      act: (bloc) =>
          bloc.add(const StatisticsPeriodChanged(StatisticsPeriod.months)),
      expect: () => [
        StatisticsLoading(period: StatisticsPeriod.months, data: _data()),
        StatisticsLoaded(
          data: _data().copyWith(period: StatisticsPeriod.months),
          period: StatisticsPeriod.months,
        ),
      ],
      verify: (_) {
        expect(repository.rateCalls, 0);
        expect(repository.ratingCalls, 0);
        expect(repository.goalCalls, 0);
      },
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'conserva datos y período si falla el cambio de período',
      build: () => StatisticsBloc(
        repository: FakeStatisticsRepository(
          data: _data(),
          failOn: StatisticsPeriod.months,
        ),
      ),
      seed: () => StatisticsLoaded(
        data: _data(),
        period: StatisticsPeriod.days,
      ),
      act: (bloc) =>
          bloc.add(const StatisticsPeriodChanged(StatisticsPeriod.months)),
      expect: () => [
        StatisticsLoading(period: StatisticsPeriod.months, data: _data()),
        StatisticsLoaded(
          data: _data(),
          period: StatisticsPeriod.days,
          snackMessage: AppStrings.changePeriodError,
        ),
      ],
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'guarda la meta y actualiza el estado sin recargar',
      build: () => StatisticsBloc(repository: repository),
      seed: () => StatisticsLoaded(
        data: _data(),
        period: StatisticsPeriod.days,
      ),
      act: (bloc) => bloc.add(const MonthlyGoalSaveRequested(70)),
      expect: () => [
        StatisticsLoaded(data: _data(), goalSaving: true),
        StatisticsLoaded(
          data: _data().copyWith(
            monthlyGoal: MonthlyGoal(
              amount: 70,
              month: DateTime.now().month,
              year: DateTime.now().year,
              offered: 28,
            ),
            monthlyOffered: 28,
          ),
          goalSaveRevision: 1,
        ),
      ],
      verify: (_) {
        expect(repository.savedAmount, 70);
        expect(repository.rateCalls, 0);
      },
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'mantiene los datos y marca error al fallar el guardado',
      build: () => StatisticsBloc(
        repository: FakeStatisticsRepository(data: _data(), failSave: true),
      ),
      seed: () => StatisticsLoaded(
        data: _data(),
        period: StatisticsPeriod.days,
      ),
      act: (bloc) => bloc.add(const MonthlyGoalSaveRequested(70)),
      expect: () => [
        StatisticsLoaded(data: _data(), goalSaving: true),
        StatisticsLoaded(
          data: _data(),
          snackMessage: AppStrings.saveGoalError,
          goalError: AppStrings.saveGoalError,
        ),
      ],
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'reintenta usando el período del estado de error',
      build: () => StatisticsBloc(repository: repository),
      seed: () => const StatisticsError(
        message: AppStrings.loadStatisticsError,
        period: StatisticsPeriod.months,
      ),
      act: (bloc) => bloc.add(const StatisticsLoadRequested()),
      expect: () => [
        const StatisticsLoading(period: StatisticsPeriod.months),
        StatisticsLoaded(
          data: _data().copyWith(period: StatisticsPeriod.months),
          period: StatisticsPeriod.months,
        ),
      ],
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'ignora respuestas de un período que ya no es el actual',
      build: () => StatisticsBloc(repository: controlled),
      seed: () => StatisticsLoaded(data: _data(), period: StatisticsPeriod.days),
      act: (bloc) async {
        bloc.add(const StatisticsLoadRequested());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const StatisticsPeriodChanged(StatisticsPeriod.months));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        controlled.complete(StatisticsPeriod.days, _data());
        controlled.complete(StatisticsPeriod.months, _data());
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
      expect: () => [
        StatisticsLoading(period: StatisticsPeriod.days, data: _data()),
        StatisticsLoading(period: StatisticsPeriod.months, data: _data()),
        StatisticsLoaded(
          data: _data().copyWith(period: StatisticsPeriod.months),
          period: StatisticsPeriod.months,
        ),
      ],
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'acepta promedio nulo',
      build: () => StatisticsBloc(
        repository: FakeStatisticsRepository(
          data: _data().copyWith(clearAverageRating: true),
        ),
      ),
      act: (bloc) => bloc.add(const StatisticsLoadRequested()),
      expect: () => [
        const StatisticsLoading(),
        StatisticsLoaded(
          data: _data().copyWith(clearAverageRating: true),
          period: StatisticsPeriod.days,
        ),
      ],
    );
  });
}
