import 'package:equatable/equatable.dart';
import '../models/statistics_data.dart';
import '../models/statistics_period.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState({
    this.period = StatisticsPeriod.days,
    this.snackMessage,
    this.goalSaving = false,
    this.goalError,
    this.goalSaveRevision = 0,
  });

  final StatisticsPeriod period;
  final String? snackMessage;
  final bool goalSaving;
  final String? goalError;
  final int goalSaveRevision;

  @override
  List<Object?> get props => [
        period,
        snackMessage,
        goalSaving,
        goalError,
        goalSaveRevision,
      ];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading({
    super.period,
    this.data,
    super.snackMessage,
    super.goalSaving,
    super.goalError,
    super.goalSaveRevision,
  });

  final StatisticsData? data;

  @override
  List<Object?> get props => [...super.props, data];
}

abstract class StatisticsDataState extends StatisticsState {
  const StatisticsDataState({
    required this.data,
    super.period,
    super.snackMessage,
    super.goalSaving,
    super.goalError,
    super.goalSaveRevision,
  });

  final StatisticsData data;

  @override
  List<Object?> get props => [...super.props, data];
}

class StatisticsLoaded extends StatisticsDataState {
  const StatisticsLoaded({
    required super.data,
    super.period,
    super.snackMessage,
    super.goalSaving,
    super.goalError,
    super.goalSaveRevision,
  });
}

class StatisticsEmpty extends StatisticsDataState {
  const StatisticsEmpty({
    required super.data,
    super.period,
    super.snackMessage,
    super.goalSaving,
    super.goalError,
    super.goalSaveRevision,
  });
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError({
    required this.message,
    super.period,
    super.snackMessage,
    super.goalSaving,
    super.goalError,
    super.goalSaveRevision,
  });

  @override
  List<Object?> get props => [message, ...super.props];
}
