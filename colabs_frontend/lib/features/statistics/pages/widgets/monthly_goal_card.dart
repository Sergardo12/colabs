import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
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
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: goal == null
          ? _NoGoalContent(onSave: onSave)
          : _GoalContent(data: data),
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
          '¿Deseas proponerte una meta del mes?',
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
          width: 76,
          height: 76,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.speed,
            size: 72,
            color: context.colors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        ElevatedButton(
          onPressed: () async {
            final result = await showMonthlyGoalDialog(context);
            if (result == null) return;
            final amount = int.tryParse(result);
            if (amount != null && amount > 0) onSave(amount);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingL,
              vertical: AppSizes.paddingS,
            ),
            minimumSize: const Size(0, AppSizes.inputSmallHeight),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
          ),
          child: Text(
            'Marcar Meta',
            style: TextStyle(
              color: context.colors.white,
              fontSize: AppSizes.fontM,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalContent extends StatelessWidget {
  final StatisticsData data;

  const _GoalContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final goal = data.monthlyGoal!;
    final reached = data.isGoalReached;

    return Column(
      children: [
        Text(
          'Meta del Mes',
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
          reached
              ? '¡Meta cumplida! ${data.monthlyOffered}/${goal.amount} servicios'
              : 'Acumulas ${data.monthlyOffered}/${goal.amount} servicios',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: AppSizes.fontM,
          ),
        ),
      ],
    );
  }
}
