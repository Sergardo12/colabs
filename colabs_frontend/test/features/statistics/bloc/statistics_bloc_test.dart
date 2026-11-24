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
import 'package:colabs_frontend/features/statistics/models/services_rate.dart';
import 'package:colabs_frontend/features/statistics/models/statistics_data.dart';
import 'package:colabs_frontend/features/statistics/models/statistics_period.dart';

class FakeStatisticsRepository implements StatisticsRepository {
  FakeStatisticsRepository({
    required this.data,
    this.failOn,
  });

  final StatisticsData data;
  final StatisticsPeriod? failOn;
  StatisticsData? replacementData;
  int? savedAmount;

  @override
  Future<StatisticsData> getStatistics(StatisticsPeriod period) async {
    if (failOn == period) throw Exception('falló');
    return (replacementData ?? data).copyWith(period: period);
  }

  @override
  Future<void> saveMonthlyGoal(int amount) async {
    savedAmount = amount;
    final now = DateTime.now();
    replacementData = data.copyWith(
      monthlyGoal: MonthlyGoal(amount: amount, month: now.month, year: now.year),
    );
  }
}

class ControlledStatisticsRepository implements StatisticsRepository {
  final Map<StatisticsPeriod, Completer<StatisticsData>> _pending =
      <StatisticsPeriod, Completer<StatisticsData>>{};

  @override
  Future<StatisticsData> getStatistics(StatisticsPeriod period) {
    final completer = Completer<StatisticsData>();
    _pending[period] = completer;
    return completer.future;
  }

  @override
  Future<void> saveMonthlyGoal(int amount) async {}

  void complete(StatisticsPeriod period, StatisticsData data) {
    _pending[period]!.complete(data);
  }
}

StatisticsData _data() {
  return StatisticsData(
    period: StatisticsPeriod.days,
    bars: const [BarDatum(key: 1, value: 12)],
    rate: const ServicesRate(requested: 3, offered: 42),
    averageRating: 4.7,
    totalServices: 42,
    monthlyOffered: 28,
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
      'carga datos iniciales',
      build: () => StatisticsBloc(repository: repository),
      act: (bloc) => bloc.add(const StatisticsLoadRequested()),
      expect: () => [
        const StatisticsLoading(),
        StatisticsLoaded(data: _data(), period: StatisticsPeriod.days),
      ],
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'cambia el período correctamente',
      build: () => StatisticsBloc(
        repository: FakeStatisticsRepository(data: _data()),
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
          data: _data().copyWith(period: StatisticsPeriod.months),
          period: StatisticsPeriod.months,
        ),
      ],
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'conserva datos y período anteriores si falla el cambio de período',
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
      'guarda la meta y refresca los datos',
      build: () => StatisticsBloc(repository: repository),
      seed: () => StatisticsLoaded(
        data: _data(),
        period: StatisticsPeriod.days,
      ),
      act: (bloc) => bloc.add(const MonthlyGoalSaveRequested(70)),
      expect: () => [
        StatisticsLoaded(
          data: _data().copyWith(
            monthlyGoal: MonthlyGoal(
              amount: 70,
              month: DateTime.now().month,
              year: DateTime.now().year,
            ),
          ),
          period: StatisticsPeriod.days,
        ),
      ],
      verify: (_) {
        expect(repository.savedAmount, 70);
      },
    );

    blocTest<StatisticsBloc, StatisticsState>(
      'reintenta usando el período del estado de error',
      build: () => StatisticsBloc(
        repository: FakeStatisticsRepository(data: _data()),
      ),
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
      act: (bloc) async {
        bloc.add(const StatisticsLoadRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const StatisticsPeriodChanged(StatisticsPeriod.months));
        await Future<void>.delayed(Duration.zero);
        controlled.complete(StatisticsPeriod.days, _data());
        await Future<void>.delayed(Duration.zero);
        controlled.complete(
          StatisticsPeriod.months,
          _data().copyWith(period: StatisticsPeriod.months),
        );
      },
      expect: () => [
        const StatisticsLoading(period: StatisticsPeriod.days),
        const StatisticsLoading(period: StatisticsPeriod.months),
        StatisticsLoaded(
          data: _data().copyWith(period: StatisticsPeriod.months),
          period: StatisticsPeriod.months,
        ),
      ],
    );
  });
}
