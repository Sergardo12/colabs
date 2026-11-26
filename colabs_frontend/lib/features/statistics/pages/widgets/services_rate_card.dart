import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../models/statistics_data.dart';

class ServicesRateCard extends StatelessWidget {
  final StatisticsData data;

  const ServicesRateCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.servicesRateTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
              child: Center(
                child: Text(
                  AppStrings.noServicesYet,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: AppSizes.fontM,
                  ),
                ),
              ),
            )
          else ...[
            Container(
              width: AppSizes.pieSize,
              height: AppSizes.pieSize,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.white,
              ),
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 0,
                  sectionsSpace: 2,
                  sections: [
                    PieChartSectionData(
                      value: data.rate.requested.toDouble(),
                      color: AppChartColors.requested,
                      radius: AppSizes.pieRadius,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: data.rate.offered.toDouble(),
                      color: const Color.fromARGB(255, 255, 136, 0),
                      radius: AppSizes.pieRadius,
                      showTitle: false,
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 350),
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSizes.paddingM,
              runSpacing: AppSizes.paddingXS,
              children: const [
                _Legend(
                  color: AppChartColors.requested,
                  label: AppStrings.requestedLegend,
                ),
                _Legend(
                  color: Color.fromARGB(255, 255, 136, 0),
                  label: AppStrings.offeredLegend,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSizes.paddingXS),
          Text(
            label,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: AppSizes.fontS,
            ),
          ),
        ],
      ),
    );
  }
}
