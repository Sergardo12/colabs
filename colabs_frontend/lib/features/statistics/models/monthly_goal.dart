import 'package:equatable/equatable.dart';

class MonthlyGoal extends Equatable {
  final int amount;
  final int month;
  final int year;

  const MonthlyGoal({
    required this.amount,
    required this.month,
    required this.year,
  });

  bool isCurrent(DateTime now) => month == now.month && year == now.year;

  @override
  List<Object?> get props => [amount, month, year];
}
