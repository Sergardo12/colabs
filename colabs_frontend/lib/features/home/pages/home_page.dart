import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Center(
        child: Text(
          '🎉 Bienvenido a Colabs',
          style: TextStyle(
            color:      AppColors.primary,
            fontSize:   24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}