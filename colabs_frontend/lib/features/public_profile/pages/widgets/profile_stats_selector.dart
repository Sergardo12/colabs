import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/public_colab_model.dart';

/// Selector de estadísticas del perfil público:
/// POST | CALIFICACIÓN | LIKES. Son tabs interactivos.
class ProfileStatsSelector extends StatelessWidget {
  static const double _valueSize = 32.0;

  final PublicProfileStats stats;
  final int                selectedIndex;
  final ValueChanged<int>  onSelected;

  const ProfileStatsSelector({
    super.key,
    required this.stats,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final values = [
      '${stats.postCount}',
      stats.averageRating.toStringAsFixed(1),
      '${stats.totalLikes}',
    ];
    const labels = ['POST', 'CALIFICACIÓN', 'LIKES'];

    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical:   AppSizes.paddingL,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (index) {
          final active = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Column(
              children: [
                Text(
                  values[index],
                  style: TextStyle(
                    color: active
                        ? context.colors.primary
                        : context.colors.textPrimary,
                    fontSize:   _valueSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXS),
                Text(
                  labels[index],
                  style: TextStyle(
                    color: active
                        ? context.colors.primary
                        : context.colors.textSecondary,
                    fontSize:   AppSizes.fontM,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
