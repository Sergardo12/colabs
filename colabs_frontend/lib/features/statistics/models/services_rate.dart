import 'package:equatable/equatable.dart';

class ServicesRate extends Equatable {
  final int requested;
  final int offered;

  const ServicesRate({required this.requested, required this.offered});

  static const ServicesRate empty = ServicesRate(requested: 0, offered: 0);

  factory ServicesRate.fromJson(Map<String, dynamic> json) {
    return ServicesRate(
      requested: (json['requested'] as num).toInt(),
      offered: (json['offered'] as num).toInt(),
    );
  }

  @override
  List<Object?> get props => [requested, offered];
}
