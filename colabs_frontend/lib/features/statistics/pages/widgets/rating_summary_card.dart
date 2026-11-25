import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
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
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.ratingTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: AppSizes.fontM,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: AppChartColors.star,
                  size: AppSizes.fontXXL,
                ),
                const SizedBox(width: AppSizes.paddingXS),
                Text(
                  data.averageRating == null
                      ? '—'
                      : '${data.averageRating!.toStringAsFixed(1)}/5',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: AppSizes.fontXXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
