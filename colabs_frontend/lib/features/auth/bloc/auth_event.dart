import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String name;
  final String lastName;
  final String password;
  final String phoneNumber;

  const RegisterRequested({
    required this.email,
    required this.name,
    required this.lastName,
    required this.password,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [email, name, lastName, password, phoneNumber];
}