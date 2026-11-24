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
    return Wrap(
      spacing: AppSizes.paddingS,
      runSpacing: AppSizes.paddingS,
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
    return SizedBox(
      width: AppSizes.periodButtonWidth,
      height: AppSizes.periodButtonHeight,
      child: Material(
        color: isSelected ? context.colors.primary : context.colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
              border: Border.all(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.textSecondary.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? context.colors.white
                    : context.colors.textSecondary,
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
