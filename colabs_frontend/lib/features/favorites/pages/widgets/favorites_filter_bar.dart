import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/favorite_filter.dart';

/// Barra de filtro "Trabajador | Publicaciones" alineada a la derecha
class FavoritesFilterBar extends StatelessWidget {
  final FavoriteFilterType activeFilter;
  final ValueChanged<FavoriteFilterType> onFilterChanged;

  const FavoritesFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FilterOption(
          label:    'Trabajador',
          isActive: activeFilter == FavoriteFilterType.workers,
          onTap:    () => onFilterChanged(FavoriteFilterType.workers),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingS),
          child: Text(
            '|',
            style: TextStyle(
              color:    context.colors.textSecondary.withOpacity(0.4),
              fontSize: AppSizes.fontM,
            ),
          ),
        ),
        _FilterOption(
          label:    'Publicaciones',
          isActive: activeFilter == FavoriteFilterType.posts,
          onTap:    () => onFilterChanged(FavoriteFilterType.posts),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Icon(
          Icons.filter_list,
          color: context.colors.textSecondary,
          size:  20,
        ),
      ],
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXS),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? context.colors.primary
                : context.colors.textSecondary,
            fontSize:   AppSizes.fontM,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
