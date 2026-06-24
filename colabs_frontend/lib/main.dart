import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app.dart';
import 'core/network/api_client.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/auth_service.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/home/data/home_repository.dart';
import 'features/home/data/home_service.dart';

void main() {
  final dio            = ApiClient.create();
  final secureStorage  = const FlutterSecureStorage();

  // Auth
  final authService    = AuthService(dio);
  final authRepository = AuthRepository(
    authService:   authService,
    secureStorage: secureStorage,
  );

  // Home
  final homeService    = HomeService(dio);
  final homeRepository = HomeRepository(
    homeService:   homeService,
    secureStorage: secureStorage,
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider(
          create: (_) => HomeBloc(homeRepository: homeRepository),
        ),
      ],
      child: const ColabsApp(),
    ),
  );
}