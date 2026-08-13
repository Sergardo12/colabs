import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: const Center(child: Text('Historial')),
    );
  }
}