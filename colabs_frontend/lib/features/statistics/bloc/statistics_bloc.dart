import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../data/statistics_repository.dart';
import '../models/statistics_data.dart';
import '../models/statistics_period.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  StatisticsBloc({required this._repository})
      : super(const StatisticsInitial()) {
    on<StatisticsLoadRequested>(_onLoadRequested);
    on<StatisticsPeriodChanged>(
      _onPeriodChanged,
      transformer: restartable<StatisticsPeriodChanged>(),
    );
    on<MonthlyGoalSaveRequested>(_onGoalSaveRequested);
  }

  final StatisticsRepository _repository;

  Future<void> _onLoadRequested(
    StatisticsLoadRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    final previous = state;
    final period = previous.period;
    emit(StatisticsLoading(period: period, data: _dataOf(previous)));
    await _load(
      period,
      emit,
      withErrorState: true,
      previousState: previous,
    );
  }

  Future<void> _onPeriodChanged(
    StatisticsPeriodChanged event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state.period == event.period) return;
    final previous = state;
    emit(StatisticsLoading(period: event.period, data: _dataOf(previous)));
    await _load(
      event.period,
      emit,
      withErrorState: false,
      previousState: previous,
    );
  }

  Future<void> _onGoalSaveRequested(
    MonthlyGoalSaveRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    final current = state;
    if (current is! StatisticsDataState) return;
    final period = current.period;

    try {
      await _repository.saveMonthlyGoal(event.amount);
      if (state.period != period) return;

      final data = await _repository.getStatistics(period);
      if (state.period != period) return;

      emit(_stateFor(data, period));
    } catch (_) {
      if (state.period != period) return;
      emit(_failureState(current, AppStrings.saveGoalError));
    }
  }

  Future<void> _load(
    StatisticsPeriod period,
    Emitter<StatisticsState> emit, {
    required bool withErrorState,
    StatisticsState? previousState,
  }) async {
    try {
      final data = await _repository.getStatistics(period);
      if (state.period != period) return;
      emit(_stateFor(data, period));
    } catch (_) {
      if (state.period != period) return;
      if (withErrorState) {
        emit(
          StatisticsError(
            message: AppStrings.loadStatisticsError,
            period: period,
          ),
        );
      } else {
        emit(
          _failureState(
            previousState ?? state,
            AppStrings.changePeriodError,
          ),
        );
      }
    }
  }

  StatisticsData? _dataOf(StatisticsState state) {
    return state is StatisticsDataState ? state.data : null;
  }

  StatisticsState _stateFor(StatisticsData data, StatisticsPeriod period) {
    if (data.isEmpty) {
      return StatisticsEmpty(data: data, period: period);
    }
    return StatisticsLoaded(data: data, period: period);
  }

  StatisticsState _failureState(StatisticsState previous, String message) {
    if (previous is StatisticsLoaded) {
      return StatisticsLoaded(
        data: previous.data,
        period: previous.period,
        snackMessage: message,
      );
    }
    if (previous is StatisticsEmpty) {
      return StatisticsEmpty(
        data: previous.data,
        period: previous.period,
        snackMessage: message,
      );
    }
    return StatisticsError(
      message: message,
      period: previous.period,
    );
  }
}
