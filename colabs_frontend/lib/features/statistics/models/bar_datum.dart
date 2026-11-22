import 'package:equatable/equatable.dart';

class BarDatum extends Equatable {
  final int key;
  final double value;

  const BarDatum({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}
