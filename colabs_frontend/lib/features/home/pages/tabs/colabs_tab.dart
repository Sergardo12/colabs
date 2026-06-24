import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ColabsTab extends StatelessWidget {
  const ColabsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text('Colaboradores')),
    );
  }
}