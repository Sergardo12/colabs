import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../models/statistics_data.dart';
import '../../models/statistics_labels.dart';

class ServicesBarChart extends StatelessWidget {
  final StatisticsData data;

  const ServicesBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final interval = data.yAxisInterval.toDouble();
    final axisColor = AppChartColors.axis;

    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ChartAxesPainter(color: axisColor),
            ),
          ),
          Positioned(
            left: 30,
            right: 12,
            top: 24,
            bottom: 44,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: data.yAxisMax.toDouble(),
                barTouchData: const BarTouchData(enabled: false),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: context.colors.textSecondary.withValues(alpha: 0.14),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: List<BarChartGroupData>.generate(data.bars.length, (index) {
                  final bar = data.bars[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: bar.value,
                        color: AppChartColors.barPalette[
                            index % AppChartColors.barPalette.length],
                        width: 18,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppSizes.radiusS),
                        ),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: context.colors.textSecondary,
                            fontSize: AppSizes.fontS,
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if (index < 0 || index >= data.bars.length) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          angle: -0.9,
                          fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                          child: Text(
                            StatisticsLabels.forBar(data.bars[index].key, data.period),
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: AppSizes.fontS,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              duration: const Duration(milliseconds: 350),
            ),
          ),
          Positioned(
            left: 2,
            top: 6,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                'Servicios',
                style: TextStyle(
                  color: axisColor,
                  fontSize: AppSizes.fontS,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 8,
            child: Text(
              StatisticsLabels.periodTitle(data.period),
              style: TextStyle(
                color: axisColor,
                fontSize: AppSizes.fontS,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartAxesPainter extends CustomPainter {
  final Color color;

  const _ChartAxesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const left = 30.0;
    const bottomFromTop = 44.0;
    final bottom = size.height - bottomFromTop;

    canvas.drawLine(
      Offset(left, size.height - bottomFromTop),
      Offset(left, 18),
      paint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(size.width - 16, bottom),
      paint,
    );

    _drawArrow(canvas, Offset(left, 18), -math.pi / 2, paint);
    _drawArrow(canvas, Offset(size.width - 16, bottom), 0, paint);
  }

  void _drawArrow(Canvas canvas, Offset tip, double angle, Paint paint) {
    const size = 7.0;
    final left = tip + Offset(
          size * math.cos(angle + 2.6),
          size * math.sin(angle + 2.6),
        );
    final right = tip + Offset(
          size * math.cos(angle - 2.6),
          size * math.sin(angle - 2.6),
        );
    canvas.drawLine(tip, left, paint);
    canvas.drawLine(tip, right, paint);
  }

  @override
  bool shouldRepaint(covariant _ChartAxesPainter oldDelegate) =>
      oldDelegate.color != color;
}
