import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/statistics_data.dart';

class RatingSummaryCard extends StatelessWidget {
  final StatisticsData data;

  const RatingSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Promedio de\nCalificación',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: AppSizes.fontM,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: AppChartColors.star, size: 24),
              const SizedBox(width: AppSizes.paddingXS),
              Text(
                data.isEmpty ? '—' : '${data.averageRating.toStringAsFixed(1)}/5',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: AppSizes.fontXXL,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
