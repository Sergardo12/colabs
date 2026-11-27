import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../data/statistics_repository.dart';
import '../models/monthly_goal.dart';
import '../models/services_offered_response.dart';
import '../models/services_rate.dart';
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
    emit(
      StatisticsLoading(
        period: period,
        data: _dataOf(previous),
        goalSaving: previous.goalSaving,
        goalError: previous.goalError,
        goalSaveRevision: previous.goalSaveRevision,
      ),
    );
    await _loadInitial(period, emit, previousState: previous);
  }

  Future<void> _onPeriodChanged(
    StatisticsPeriodChanged event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state.period == event.period) return;
    final previous = state;
    emit(
      StatisticsLoading(
        period: event.period,
        data: _dataOf(previous),
        goalSaving: previous.goalSaving,
        goalError: previous.goalError,
        goalSaveRevision: previous.goalSaveRevision,
      ),
    );
    await _loadPeriod(event.period, emit, previousState: previous);
  }

  Future<void> _onGoalSaveRequested(
    MonthlyGoalSaveRequested event,
    Emitter<StatisticsState> emit,
  ) async {
    final current = state;
    if (current is! StatisticsDataState || current.goalSaving) return;

    emit(
      _withFlags(current, goalSaving: true, goalError: null),
    );

    try {
      final goal = await _repository.saveMonthlyGoal(event.amount);
      final latest = state;
      if (latest is! StatisticsDataState) return;

      emit(
        _withFlags(
          latest,
          data: latest.data.copyWith(
            monthlyGoal: goal,
            monthlyOffered: goal.offered,
          ),
          goalSaving: false,
          goalError: null,
          goalSaveRevision: latest.goalSaveRevision + 1,
        ),
      );
    } catch (_) {
      final latest = state;
      if (latest is! StatisticsDataState) return;

      emit(
        _withFlags(
          latest,
          goalSaving: false,
          goalError: AppStrings.saveGoalError,
          snackMessage: AppStrings.saveGoalError,
        ),
      );
    }
  }

  Future<void> _loadInitial(
    StatisticsPeriod period,
    Emitter<StatisticsState> emit, {
    required StatisticsState previousState,
  }) async {
    try {
      final values = await Future.wait<dynamic>([
        _repository.getServicesOffered(period),
        _repository.getServicesTotal(period),
        _repository.getServicesRate(),
        _repository.getAverageRating(),
        _repository.getMonthlyGoal(),
      ]);
      if (state.period != period) return;

      final data = _compose(
        period: period,
        offered: values[0] as ServicesOfferedResponse,
        total: values[1] as int,
        rate: values[2] as ServicesRate,
        averageRating: values[3] as double?,
        goal: values[4] as MonthlyGoal?,
      );
      emit(_stateFor(data, period));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('StatisticsBloc._loadInitial: $error');
        debugPrintStack(
          label: 'StatisticsBloc._loadInitial',
          stackTrace: stackTrace,
        );
      }
      if (state.period != period) return;
      emit(
        StatisticsError(
          message: AppStrings.loadStatisticsError,
          period: period,
          goalSaveRevision: previousState.goalSaveRevision,
        ),
      );
    }
  }

  Future<void> _loadPeriod(
    StatisticsPeriod period,
    Emitter<StatisticsState> emit, {
    required StatisticsState previousState,
  }) async {
    try {
      final values = await Future.wait<dynamic>([
        _repository.getServicesOffered(period),
        _repository.getServicesTotal(period),
      ]);
      if (state.period != period) return;

      final currentData = _dataOf(state) ?? _dataOf(previousState);
      if (currentData == null) return;

      final offered = values[0] as ServicesOfferedResponse;
      final data = currentData.copyWith(
        period: period,
        bars: offered.bars,
        accountCreatedYear: offered.accountCreatedYear,
        totalServices: values[1] as int,
      );
      emit(_stateFor(data, period));
    } catch (_) {
      if (state.period != period) return;
      emit(
        _failureState(
          previousState,
          AppStrings.changePeriodError,
        ),
      );
    }
  }

  StatisticsData _compose({
    required StatisticsPeriod period,
    required ServicesOfferedResponse offered,
    required int total,
    required ServicesRate rate,
    required double? averageRating,
    required MonthlyGoal? goal,
  }) {
    return StatisticsData(
      period: period,
      bars: offered.bars,
      accountCreatedYear: offered.accountCreatedYear,
      rate: rate,
      averageRating: averageRating,
      totalServices: total,
      monthlyOffered: goal?.offered ?? 0,
      monthlyGoal: goal,
    );
  }

  StatisticsData? _dataOf(StatisticsState state) {
    if (state is StatisticsDataState) return state.data;
    if (state is StatisticsLoading) return state.data;
    return null;
  }

  StatisticsState _stateFor(StatisticsData data, StatisticsPeriod period) {
    final revision = state.goalSaveRevision;
    if (data.isEmpty) {
      return StatisticsEmpty(data: data, period: period, goalSaveRevision: revision);
    }
    return StatisticsLoaded(data: data, period: period, goalSaveRevision: revision);
  }

  StatisticsState _failureState(StatisticsState previous, String message) {
    if (previous is StatisticsLoaded) {
      return StatisticsLoaded(
        data: previous.data,
        period: previous.period,
        snackMessage: message,
        goalSaving: false,
        goalError: previous.goalError,
        goalSaveRevision: previous.goalSaveRevision,
      );
    }
    if (previous is StatisticsEmpty) {
      return StatisticsEmpty(
        data: previous.data,
        period: previous.period,
        snackMessage: message,
        goalSaving: false,
        goalError: previous.goalError,
        goalSaveRevision: previous.goalSaveRevision,
      );
    }
    return StatisticsError(
      message: message,
      period: previous.period,
      goalSaveRevision: previous.goalSaveRevision,
    );
  }

  StatisticsState _withFlags(
    StatisticsDataState current, {
    StatisticsData? data,
    bool? goalSaving,
    String? goalError,
    String? snackMessage,
    int? goalSaveRevision,
  }) {
    final nextData = data ?? current.data;
    if (current is StatisticsLoaded) {
      return StatisticsLoaded(
        data: nextData,
        period: current.period,
        snackMessage: snackMessage ?? current.snackMessage,
        goalSaving: goalSaving ?? current.goalSaving,
        goalError: goalError,
        goalSaveRevision: goalSaveRevision ?? current.goalSaveRevision,
      );
    }
    return StatisticsEmpty(
      data: nextData,
      period: current.period,
      snackMessage: snackMessage ?? current.snackMessage,
      goalSaving: goalSaving ?? current.goalSaving,
      goalError: goalError,
      goalSaveRevision: goalSaveRevision ?? current.goalSaveRevision,
    );
  }
}
