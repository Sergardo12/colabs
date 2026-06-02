import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required AuthRepository authRepository})
      : authRepository = authRepository,
        super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  /// Maneja el evento LoginRequested
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.login(
        email:    event.email,
        password: event.password,
      );
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  /// Maneja el evento RegisterRequested
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.register(
        email:       event.email,
        name:        event.name,
        lastName:    event.lastName,
        password:    event.password,
        phoneNumber: event.phoneNumber,
      );
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(message: _parseError(e)));
    }
  }

  /// Convierte errores HTTP a mensajes legibles para el usuario
  String _parseError(Object e) {
    if (e.toString().contains('401')) return 'Credenciales incorrectas';
    if (e.toString().contains('409')) return 'El email ya está registrado';
    if (e.toString().contains('SocketException')) return 'Sin conexión a internet';
    return 'Ocurrió un error. Intenta de nuevo';
  }
}