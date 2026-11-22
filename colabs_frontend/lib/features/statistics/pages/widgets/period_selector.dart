import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/statistics_labels.dart';
import '../../models/statistics_period.dart';

class PeriodSelector extends StatelessWidget {
  final StatisticsPeriod selected;
  final ValueChanged<StatisticsPeriod> onChanged;

  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _PeriodButton(
          label: StatisticsLabels.periodTitle(StatisticsPeriod.days),
          isSelected: selected == StatisticsPeriod.days,
          onTap: () => onChanged(StatisticsPeriod.days),
        ),
        _PeriodButton(
          label: StatisticsLabels.periodTitle(StatisticsPeriod.months),
          isSelected: selected == StatisticsPeriod.months,
          onTap: () => onChanged(StatisticsPeriod.months),
        ),
        _PeriodButton(
          label: StatisticsLabels.periodTitle(StatisticsPeriod.years),
          isSelected: selected == StatisticsPeriod.years,
          onTap: () => onChanged(StatisticsPeriod.years),
        ),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingXS),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: Container(
            height: AppSizes.inputSmallHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? context.colors.primary : context.colors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              border: Border.all(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.textSecondary.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? context.colors.white
                    : context.colors.textPrimary,
                fontSize: AppSizes.fontS,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
