import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Text(
          'Colabs',
          style: TextStyle(
            color:         AppColors.white,
            fontSize:      40,
            fontWeight:    FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}