import 'package:equatable/equatable.dart';

abstract class BecomeColabEvent extends Equatable {
  const BecomeColabEvent();

  @override
  List<Object?> get props => [];
}

class OccupationsLoadRequested extends BecomeColabEvent {
  const OccupationsLoadRequested();
}

class BecomeColabSubmitted extends BecomeColabEvent {
  final String description;
  final String experience;
  final String dni;
  final List<String> occupationIds;
  final String? certifications;

  const BecomeColabSubmitted({
    required this.description,
    required this.experience,
    required this.dni,
    required this.occupationIds,
    this.certifications,
  });

  @override
  List<Object?> get props =>
      [description, experience, dni, occupationIds, certifications];
}