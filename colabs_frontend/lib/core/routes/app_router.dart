import 'package:colabs_frontend/features/auth/pages/login_page.dart';
import 'package:colabs_frontend/features/auth/pages/register_page.dart';
import 'package:colabs_frontend/features/splash/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import '../../features/splash/pages/splash_page.dart';

class AppRouter {
  AppRouter._();

  static const String splash  = '/';
  static const String welcome = '/welcome';
  static const String login   = '/login';
  static const String register = '/register';
  static const String home    = '/home';

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
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}