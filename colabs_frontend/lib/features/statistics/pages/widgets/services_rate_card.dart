import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/statistics_data.dart';

class ServicesRateCard extends StatelessWidget {
  final StatisticsData data;

  const ServicesRateCard({super.key, required this.data});

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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tasa de\nservicios',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: AppSizes.fontL,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingL),
              child: Center(
                child: Text(
                  'Aún no tienes servicios',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: AppSizes.fontM,
                  ),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 110,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                  sections: [
                    PieChartSectionData(
                      value: data.rate.requested.toDouble(),
                      color: AppChartColors.requested,
                      radius: 42,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: data.rate.offered.toDouble(),
                      color: AppChartColors.offered,
                      radius: 42,
                      showTitle: false,
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 350),
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(
                  color: AppChartColors.requested,
                  label: 'Solicitados',
                ),
                const SizedBox(width: AppSizes.paddingM),
                _Legend(
                  color: AppChartColors.offered,
                  label: 'Ofrecidos',
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSizes.radiusS / 2),
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
    );
  }
}
