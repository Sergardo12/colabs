import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../bloc/statistics_bloc.dart';
import '../../models/statistics_data.dart';
import 'goal_gauge.dart';
import 'monthly_goal_dialog.dart';

class MonthlyGoalCard extends StatelessWidget {
  final StatisticsData data;
  final StatisticsBloc bloc;

  const MonthlyGoalCard({super.key, required this.data, required this.bloc});

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
          ? _NoGoalContent(bloc: bloc)
          : _GoalContent(data: data, bloc: bloc),
    );
  }
}

Future<void> _openGoalDialog(
  BuildContext context,
  StatisticsBloc bloc,
  int? amount,
) async {
  await showMonthlyGoalDialog(context, bloc: bloc, amount: amount);
}

class _GoalButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GoalButton({required this.label, required this.onPressed});

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
  final StatisticsBloc bloc;

  const _NoGoalContent({required this.bloc});

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
          onPressed: () => _openGoalDialog(context, bloc, null),
        ),
      ],
    );
  }
}

class _GoalContent extends StatelessWidget {
  final StatisticsData data;
  final StatisticsBloc bloc;

  const _GoalContent({required this.data, required this.bloc});

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
            fontSize: AppSizes.fontL,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 0),
        GoalGauge(percent: data.goalPercent),
        const SizedBox(height: 20),
        Text(
          AppStrings.goalProgressSummary(data.monthlyOffered, goal.amount),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: AppSizes.fontS,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        _GoalButton(
          label: AppStrings.editGoal,
          onPressed: () => _openGoalDialog(context, bloc, goal.amount),
        ),
      ],
    );
  }
}
