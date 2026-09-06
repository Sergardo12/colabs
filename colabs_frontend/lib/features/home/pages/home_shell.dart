import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../../favorites/bloc/favorites_bloc.dart';
import '../../favorites/bloc/favorites_event.dart';
import '../../favorites/bloc/post_favorites_bloc.dart';
import '../../favorites/bloc/post_favorites_event.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import '../../profile/bloc/profile_state.dart';
import 'tabs/home_tab.dart';
import 'tabs/colabs_tab.dart';
import 'tabs/search_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/favorites_tab.dart';
import 'tabs/specialty_requests_tab.dart';
import 'widgets/bottom_nav_bar.dart';
import '../../../features/profile/pages/widgets/app_drawer.dart';
import '../../../core/routes/app_router.dart';
import '../../chat/data/chat_repository.dart';
import '../../notifications/bloc/notification_bloc.dart';
import '../../notifications/bloc/notification_event.dart';
import '../../notifications/models/notification_model.dart';
import '../../service_request/bloc/service_request_bloc.dart';
import '../../service_request/bloc/service_request_event.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
    context.read<FavoritesBloc>().add(const FavoritesLoadRequested());
    context.read<PostFavoritesBloc>().add(const PostFavoritesLoadRequested());
    _setupSocket();
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    context.read<ChatRepository>().disconnect();
    super.dispose();
  }

  void _setupSocket() {
    final chatRepository = context.read<ChatRepository>();

    // Escuchar notificaciones de propuesta en tiempo real
    chatRepository.onNewNotification((data) {
      final notification = NotificationModel.fromJson(data);
      context.read<NotificationBloc>().add(
            NotificationPushReceived(notification),
          );
      // Actualiza el contador de propuestas en My Requests
      context.read<ServiceRequestBloc>().add(const MyRequestsLoadRequested());
    });

    // Ciclo de vida: reconectar si la app vuelve de background
    _lifecycleListener = AppLifecycleListener(
      onResume: () async {
        if (!chatRepository.isSocketConnected) {
          try {
            await chatRepository.connectSocket();
            final profile = context.read<ProfileBloc>().state;
            if (profile is ProfileSuccess) {
              chatRepository.registerUser(profile.user.id);
            }
          } catch (_) {}
        }
        // Refresca notificaciones + contador al volver
        context.read<NotificationBloc>().add(const NotificationsLoadRequested());
        context.read<ServiceRequestBloc>().add(const MyRequestsLoadRequested());
      },
      onHide: () {
        // En background: desconecta para ahorrar batería / recursos
        chatRepository.disconnect();
      },
    );
  }

  bool _isColaborador(ProfileState state) {
    return state is ProfileSuccess && state.colab != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (prev, curr) {
        final prevReady = prev is ProfileSuccess;
        final currReady = curr is ProfileSuccess;
        return !prevReady && currReady;
      },
      listener: (context, profileState) {
        if (profileState is ProfileSuccess) {
          final chatRepository = context.read<ChatRepository>();
          if (!chatRepository.isSocketConnected) {
            chatRepository.connectSocket().then((_) {
              chatRepository.registerUser(profileState.user.id);
            });
          } else {
            chatRepository.registerUser(profileState.user.id);
          }
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (prev, curr) {
          final prevColab = prev is ProfileSuccess && prev.colab != null;
          final currColab = curr is ProfileSuccess && curr.colab != null;
          return prevColab != currColab;
        },
        builder: (context, profileState) {
          final isColab = _isColaborador(profileState);
          final tabs = [
            const HomeTab(),
            const ColabsTab(),
            const SearchTab(),
            const HistoryTab(),
            if (isColab) const SpecialtyRequestsTab() else const FavoritesTab(),
          ];
          return Scaffold(
            backgroundColor: context.colors.background,
            extendBody: true,
            body: IndexedStack(
              index: _currentIndex.clamp(0, tabs.length - 1),
              children: tabs,
            ),
            bottomNavigationBar: ColabsBottomNav(
              currentIndex: _currentIndex,
              isColaborador: isColab,
              onTap: (index) {
                if (index == 2) {
                  Navigator.pushNamed(context, AppRouter.requestMap);
                  return;
                }
                if (index == 0 && _currentIndex != 0) {
                  context.read<HomeBloc>().add(const FeedRefreshRequested());
                }
                setState(() => _currentIndex = index);

                if (index == 4 && !isColab) {
                  context
                      .read<FavoritesBloc>()
                      .add(const FavoritesLoadRequested());
                  context
                      .read<PostFavoritesBloc>()
                      .add(const PostFavoritesLoadRequested());
                }
              },
            ),
            drawer: const AppDrawer(),
          );
        },
      ),
    );
  }
}
