import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/request_status_filter.dart';

class RequestStatusFilterBar extends StatelessWidget {
  final RequestStatusFilter selected;
  final ValueChanged<RequestStatusFilter> onSelected;

  const RequestStatusFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = RequestStatusFilter.values;

    return Container(
      color: context.colors.surface,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
        child: Row(
          children: [
            for (var i = 0; i < filters.length; i++) ...[
              _FilterButton(
                filter: filters[i],
                selected: filters[i] == selected,
                onTap: () => onSelected(filters[i]),
              ),
              if (i != filters.length - 1)
                const SizedBox(width: AppSizes.paddingS),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final RequestStatusFilter filter;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM,
              vertical: AppSizes.paddingS,
            ),
            decoration: BoxDecoration(
              color: selected ? primary : primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              border: Border.all(
                color: selected ? primary : primary.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              filter.label,
              style: TextStyle(
                color: selected ? Colors.white : primary,
                fontSize: AppSizes.fontM,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
