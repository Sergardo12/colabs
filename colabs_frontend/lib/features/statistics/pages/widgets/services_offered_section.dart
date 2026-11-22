import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/statistics_data.dart';
import '../../models/statistics_period.dart';
import 'period_selector.dart';
import 'services_bar_chart.dart';

class ServicesOfferedSection extends StatelessWidget {
  final StatisticsData data;
  final ValueChanged<StatisticsPeriod> onPeriodChanged;

  const ServicesOfferedSection({
    super.key,
    required this.data,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios Ofrecidos',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: AppSizes.fontL,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        PeriodSelector(
          selected: data.period,
          onChanged: onPeriodChanged,
        ),
        const SizedBox(height: AppSizes.paddingM),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: ServicesBarChart(data: data),
        ),
      ],
    );
  }
}
