import 'package:equatable/equatable.dart';
import 'bar_datum.dart';
import 'statistics_period.dart';

class ServicesOfferedResponse extends Equatable {
  final StatisticsPeriod period;
  final int accountCreatedYear;
  final List<BarDatum> bars;

  const ServicesOfferedResponse({
    required this.period,
    required this.accountCreatedYear,
    required this.bars,
  });

  factory ServicesOfferedResponse.fromJson(Map<String, dynamic> json) {
    return ServicesOfferedResponse(
      period: statisticsPeriodFromValue(json['period'] as String? ?? 'days'),
      accountCreatedYear: (json['accountCreatedYear'] as num?)?.toInt() ??
          DateTime.now().year,
      bars: (json['bars'] as List<dynamic>? ?? const [])
          .map((item) => BarDatum.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [period, accountCreatedYear, bars];
}
