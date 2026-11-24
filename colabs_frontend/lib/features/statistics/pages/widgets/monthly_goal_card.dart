import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../models/statistics_data.dart';
import 'goal_gauge.dart';
import 'monthly_goal_dialog.dart';

class MonthlyGoalCard extends StatelessWidget {
  final StatisticsData data;
  final ValueChanged<int> onSave;

  const MonthlyGoalCard({
    super.key,
    required this.data,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final goal = data.monthlyGoal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: goal == null
          ? _NoGoalContent(onSave: onSave)
          : _GoalContent(data: data, onSave: onSave),
    );
  }
}

Future<void> _openGoalDialog(
  BuildContext context,
  ValueChanged<int> onSave,
) async {
  final result = await showMonthlyGoalDialog(context);
  if (result == null) return;
  final amount = int.tryParse(result);
  if (amount != null && amount > 0) onSave(amount);
}

class _GoalButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GoalButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: context.colors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingXS,
        ),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.white,
          fontSize: AppSizes.fontS,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NoGoalContent extends StatelessWidget {
  final ValueChanged<int> onSave;

  const _NoGoalContent({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.monthlyGoalQuestion,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Image.asset(
          'assets/images/work_goal.png',
          width: AppSizes.goalImageSize,
          height: AppSizes.goalImageSize,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.speed,
            size: AppSizes.goalImageSize,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        _GoalButton(
          label: AppStrings.markGoal,
          onPressed: () => _openGoalDialog(context, onSave),
        ),
      ],
    );
  }
}

class _GoalContent extends StatelessWidget {
  final StatisticsData data;
  final ValueChanged<int> onSave;

  const _GoalContent({
    required this.data,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final goal = data.monthlyGoal!;

    return Column(
      children: [
        Text(
          AppStrings.monthlyGoalTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: AppSizes.fontM,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        GoalGauge(percent: data.goalPercent),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          '${AppStrings.goalSummaryLabel}: ${goal.amount} '
          '${AppStrings.goalSummarySeparator} '
          '${AppStrings.goalProgressLabel} ${data.monthlyOffered}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: AppSizes.fontM,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        _GoalButton(
          label: AppStrings.editGoal,
          onPressed: () => _openGoalDialog(context, onSave),
        ),
      ],
    );
  }
}
