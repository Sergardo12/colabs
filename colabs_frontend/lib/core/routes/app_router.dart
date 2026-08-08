import 'package:colabs_frontend/features/auth/pages/login_page.dart';
import 'package:colabs_frontend/features/auth/pages/register_page.dart';
import 'package:colabs_frontend/features/home/pages/home_shell.dart';
import 'package:colabs_frontend/features/profile/pages/profile_page.dart';
import 'package:colabs_frontend/features/splash/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import '../../features/splash/pages/splash_page.dart';
import '../../features/profile/pages/become_colab_page.dart';
import '../../features/profile/pages/edit_colab_profile_page.dart';

class AppRouter {
  AppRouter._();

  static const String splash  = '/';
  static const String welcome = '/welcome';
  static const String login   = '/login';
  static const String register = '/register';
  static const String home    = '/home';
  static const String profile = '/profile';
  static const String becomeColab = '/become-colab';
  static const String editColabProfile = '/edit-colab-profile';

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
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}