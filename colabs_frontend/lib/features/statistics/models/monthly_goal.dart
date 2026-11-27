import 'package:equatable/equatable.dart';

class MonthlyGoal extends Equatable {
  final int amount;
  final int month;
  final int year;
  final int offered;

  const MonthlyGoal({
    required this.amount,
    required this.month,
    required this.year,
    this.offered = 0,
  });

  factory MonthlyGoal.fromJson(Map<String, dynamic> json) {
    return MonthlyGoal(
      amount: (json['amount'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      year: (json['year'] as num).toInt(),
      offered: (json['offered'] as num?)?.toInt() ?? 0,
    );
  }

  bool isCurrent(DateTime now) => month == now.month && year == now.year;

  MonthlyGoal copyWith({
    int? amount,
    int? month,
    int? year,
    int? offered,
  }) {
    return MonthlyGoal(
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      offered: offered ?? this.offered,
    );
  }

  @override
  List<Object?> get props => [amount, month, year, offered];
}
