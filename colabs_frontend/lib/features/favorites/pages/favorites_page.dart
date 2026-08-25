import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../home/pages/tabs/favorites_tab.dart';

class StandaloneFavoritesPage extends StatelessWidget {
  const StandaloneFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        title: Text(
          'Favoritos',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: AppSizes.fontXL,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const FavoritesTab(),
    );
  }
}
