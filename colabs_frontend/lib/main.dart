import 'package:colabs_frontend/core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/auth_service.dart';

void main() {
  final dio            = ApiClient.create();
  final authService    = AuthService(dio);
  final secureStorage  = const FlutterSecureStorage();
  final authRepository = AuthRepository(
    authService:    authService,
    secureStorage:  secureStorage,
  );

  runApp(
    BlocProvider(
      create: (_) => AuthBloc(authRepository: authRepository),
      child:  const ColabsApp(),
    ),
  );
}