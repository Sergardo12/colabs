import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/statistics_data.dart';

class TotalServicesCard extends StatelessWidget {
  final StatisticsData data;

  const TotalServicesCard({super.key, required this.data});

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
            'Servicios Totales\nBrindados',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: AppSizes.fontM,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '${data.totalServices}',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: AppSizes.fontXXL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            'Servicios',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: AppSizes.fontM,
            ),
          ),
        ],
      ),
    );
  }
}
