import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text('Historial')),
    );
  }
}