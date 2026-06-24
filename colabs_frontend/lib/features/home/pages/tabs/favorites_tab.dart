import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text('Favoritos')),
    );
  }
}