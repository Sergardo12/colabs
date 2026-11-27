import 'package:equatable/equatable.dart';
import '../models/statistics_period.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class StatisticsLoadRequested extends StatisticsEvent {
  const StatisticsLoadRequested();
}

class StatisticsPeriodChanged extends StatisticsEvent {
  final StatisticsPeriod period;

  const StatisticsPeriodChanged(this.period);

  @override
  List<Object?> get props => [period];
}

class MonthlyGoalSaveRequested extends StatisticsEvent {
  final int amount;

  const MonthlyGoalSaveRequested(this.amount);

  @override
  List<Object?> get props => [amount];
}
