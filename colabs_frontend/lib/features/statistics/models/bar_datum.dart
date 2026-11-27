import 'package:equatable/equatable.dart';

class BarDatum extends Equatable {
  final int key;
  final double value;

  const BarDatum({required this.key, required this.value});

  factory BarDatum.fromJson(Map<String, dynamic> json) {
    return BarDatum(
      key: (json['key'] as num).toInt(),
      value: (json['value'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [key, value];
}
