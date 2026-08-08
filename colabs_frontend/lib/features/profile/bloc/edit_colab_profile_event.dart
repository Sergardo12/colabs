import 'package:equatable/equatable.dart';

abstract class EditColabProfileEvent extends Equatable {
  const EditColabProfileEvent();

  @override
  List<Object?> get props => [];
}

class EditColabProfileLoadRequested extends EditColabProfileEvent {
  const EditColabProfileLoadRequested();
}

class EditColabProfileSubmitted extends EditColabProfileEvent {
  final String name;
  final String lastName;
  final String phoneNumber;
  final String? dateBirth;
  final String? gender;
  final String description;
  final String experience;
  final String? certifications;
  final List<String> occupationIds;

  const EditColabProfileSubmitted({
    required this.name,
    required this.lastName,
    required this.phoneNumber,
    this.dateBirth,
    this.gender,
    required this.description,
    required this.experience,
    this.certifications,
    required this.occupationIds,
  });

  @override
  List<Object?> get props => [
        name,
        lastName,
        phoneNumber,
        dateBirth,
        gender,
        description,
        experience,
        certifications,
        occupationIds,
      ];
}
