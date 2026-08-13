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
import 'features/profile/bloc/profile_bloc.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/profile/data/profile_service.dart';
import 'features/public_profile/bloc/public_profile_bloc.dart';
import 'features/public_profile/data/public_profile_repository.dart';
import 'features/search/bloc/search_bloc.dart';
import 'features/search/data/search_repository.dart';
import 'features/search/data/search_service.dart';
import 'features/profile/bloc/become_colab_bloc.dart';
import 'features/profile/data/become_colab_repository.dart';
import 'features/profile/data/become_colab_service.dart';
import 'features/profile/bloc/edit_colab_profile_bloc.dart';
import 'features/chat/bloc/chat_bloc.dart';
import 'features/chat/data/chat_repository.dart';
import 'features/chat/data/chat_service.dart';
import 'features/chat/data/chat_socket_service.dart';
import 'core/bloc/theme/theme_bloc.dart';
import 'core/storage/theme_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tema — se carga antes de runApp para evitar flash de tema al arrancar
  final themeRepository = const ThemeRepository();
  final initialIsDark = await themeRepository.isDark();

  final dio = ApiClient.create();
  final secureStorage = const FlutterSecureStorage();

  // Auth
  final authService = AuthService(dio);
  final authRepository = AuthRepository(
    authService: authService,
    secureStorage: secureStorage,
  );

  // Home
  final homeService = HomeService(dio);
  final homeRepository = HomeRepository(
    homeService: homeService,
    secureStorage: secureStorage,
  );

  // Profile
  final profileService = ProfileService(dio);
  final profileRepository = ProfileRepository(
    profileService: profileService,
    secureStorage: secureStorage,
  );

  // Search
  final searchService = SearchService(dio);
  final searchRepository = SearchRepository(
    searchService: searchService,
    secureStorage: secureStorage,
  );

  // Become Colab
  final becomeColabService = BecomeColabService(dio);
  final becomeColabRepository = BecomeColabRepository(
    becomeColabService: becomeColabService,
    secureStorage: secureStorage,
  );

  // Chat
  final chatService = ChatService(dio);
  final chatSocketService = ChatSocketService();
  final chatRepository = ChatRepository(
    chatService: chatService,
    socketService: chatSocketService,
    secureStorage: secureStorage,
  );

// Public Profile
final publicProfileRepository = PublicProfileRepository(
  profileService: profileService,
  homeService:    homeService,
  secureStorage:  secureStorage,
);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeBloc(
            themeRepository: themeRepository,
            initialIsDark:  initialIsDark,
          ),
        ),
        BlocProvider(create: (_) => AuthBloc(authRepository: authRepository)),
        BlocProvider(create: (_) => HomeBloc(homeRepository: homeRepository)),
        BlocProvider(
          create: (_) => ProfileBloc(profileRepository: profileRepository),
        ),
        BlocProvider(
          create: (_) => SearchBloc(searchRepository: searchRepository),
        ),
        BlocProvider(
          create: (_) => BecomeColabBloc(repository: becomeColabRepository),
        ),
        BlocProvider(
          create: (_) =>
              EditColabProfileBloc(profileRepository: profileRepository),
        ),
        BlocProvider(
          create: (_) => PublicProfileBloc(repository: publicProfileRepository),
        ),
        BlocProvider(create: (_) => ChatBloc(chatRepository: chatRepository)),
      ],
      child: const ColabsApp(),
    ),
  );
}
