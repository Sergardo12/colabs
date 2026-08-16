import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../auth/bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
  await Future.delayed(const Duration(seconds: 2));
  if (!mounted) return;

  final isValid = await context.read<AuthBloc>().authRepository.isSessionValid();
  if (!mounted) return;

  if (isValid) {
    Navigator.pushReplacementNamed(context, AppRouter.home);
  } else {
    Navigator.pushReplacementNamed(context, AppRouter.welcome);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.primary,
      body: Center(
        child: Text(
          'Colabs',
          style: TextStyle(
            color:         context.colors.white,
            fontSize:      40,
            fontWeight:    FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}