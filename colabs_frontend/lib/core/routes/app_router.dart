import 'package:colabs_frontend/features/auth/pages/login_page.dart';
import 'package:colabs_frontend/features/auth/pages/register_page.dart';
import 'package:colabs_frontend/features/home/pages/home_shell.dart';
import 'package:colabs_frontend/features/profile/pages/profile_page.dart';
import 'package:colabs_frontend/features/public_profile/pages/public_profile_page.dart';
import 'package:colabs_frontend/features/splash/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/splash/pages/splash_page.dart';
import '../../features/profile/pages/become_colab_page.dart';
import '../../features/profile/pages/edit_colab_profile_page.dart';
import '../../features/profile/bloc/profile_bloc.dart';
import '../../features/profile/bloc/profile_state.dart';
import '../../features/chat/pages/chat_page.dart';
import '../../features/chat/pages/conversations_page.dart';
import '../../features/chat/models/conversation_model.dart';
import '../../features/home/models/post_model.dart';
import '../../features/service_request/pages/request_map_page.dart';
import '../../features/favorites/pages/favorites_page.dart';
import '../../features/notifications/pages/notifications_page.dart';
import '../../features/notifications/models/notification_model.dart';
import '../../features/service_request/pages/service_request_detail_page.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String becomeColab = '/become-colab';
  static const String editColabProfile = '/edit-colab-profile';
  static const String publicProfile = '/public-profile';
  static const String chat = '/chat';
  static const String conversations = '/conversations';
  static const String requestMap = '/request-map';
  static const String favorites = '/favorites';
  static const String notifications = '/notifications';
  static const String serviceRequestDetail = '/service-request-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeShell());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case becomeColab:
        return MaterialPageRoute(builder: (_) => const BecomeColabPage());
      case editColabProfile:
        return MaterialPageRoute(builder: (_) => const EditColabProfilePage());
      case publicProfile:
        return MaterialPageRoute(
          builder: (_) => PublicProfilePage(
            userId: settings.arguments as String,
          ),
        );
      case conversations:
        return MaterialPageRoute(builder: (_) => const ConversationsPage());
      case requestMap:
        return MaterialPageRoute(
          builder: (_) => const RequestMapPage(),
        );
      case favorites:
        return MaterialPageRoute(
          builder: (_) => const StandaloneFavoritesPage(),
        );
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case serviceRequestDetail:
        return MaterialPageRoute(
          builder: (_) => ServiceRequestDetailPage(
            notification: settings.arguments as NotificationModel,
          ),
        );
      case chat:
        final args = settings.arguments;
        if (args is Map) {
          final conversation = args['conversation'] as ConversationModel?;
          final post         = args['post']         as PostModel?;
          if (conversation != null) {
            return MaterialPageRoute(
              builder: (context) {
                final profileState  = context.read<ProfileBloc>().state;
                final currentUserId = profileState is ProfileSuccess
                    ? profileState.user.id
                    : '';
                return ChatPage(
                  conversation:  conversation,
                  currentUserId: currentUserId,
                  post:          post,
                );
              },
            );
          }
        }
        return MaterialPageRoute(builder: (_) => const ConversationsPage());
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}
