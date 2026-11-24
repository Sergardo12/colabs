import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../models/statistics_data.dart';
import '../../models/statistics_labels.dart';

class ServicesBarChart extends StatelessWidget {
  final StatisticsData data;

  const ServicesBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final interval = data.yAxisInterval.toDouble();
    final axisColor = AppChartColors.axis;
    final rodWidth = (180 / data.bars.length)
        .clamp(AppSizes.chartRodMinWidth, AppSizes.chartRodMaxWidth)
        .toDouble();

    return SizedBox(
      height: AppSizes.chartHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final left = AppSizes.chartLeftInset;
          final right = constraints.maxWidth - AppSizes.chartRightInset;
          final top = AppSizes.chartTopInset;
          final bottom = AppSizes.chartHeight - AppSizes.chartBottomInset;

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _ChartAxesPainter(
                    color: axisColor,
                    left: left,
                    right: right,
                    top: top,
                    bottom: bottom,
                  ),
                ),
              ),
              Positioned(
                left: left,
                right: AppSizes.chartRightInset,
                top: top,
                bottom: AppSizes.chartBottomInset,
                child: BarChart(
                  BarChartData(
                    minY: 0,
                    maxY: data.yAxisMax.toDouble(),
                    alignment: BarChartAlignment.spaceAround,
                    barTouchData: const BarTouchData(enabled: false),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: List<BarChartGroupData>.generate(
                      data.bars.length,
                      (index) {
                        final bar = data.bars[index];
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: bar.value,
                              color: AppChartColors.barPalette[
                                  index % AppChartColors.barPalette.length],
                              width: rodWidth,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(AppSizes.chartRodRadius),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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
                          reservedSize: AppSizes.chartLeftReserved,
                          getTitlesWidget: (value, meta) {
                            if (value <= 0) return const SizedBox.shrink();
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: context.colors.textSecondary,
                                  fontSize: AppSizes.fontS,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: AppSizes.chartBottomReserved,
                          getTitlesWidget: (value, meta) {
                            final index = value.round();
                            if (index < 0 || index >= data.bars.length) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              angle: -0.9,
                              fitInside:
                                  SideTitleFitInsideData.fromTitleMeta(meta),
                              child: Text(
                                StatisticsLabels.forBar(
                                  data.bars[index].key,
                                  data.period,
                                ),
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
                left: 0,
                top: 0,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    AppStrings.servicesAxis,
                    style: TextStyle(
                      color: axisColor,
                      fontSize: AppSizes.fontS,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: AppSizes.chartBottomInset - AppSizes.fontS / 2,
                child: Text(
                  StatisticsLabels.axisTitle(data.period),
                  style: TextStyle(
                    color: axisColor,
                    fontSize: AppSizes.fontS,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChartAxesPainter extends CustomPainter {
  final Color color;
  final double left;
  final double right;
  final double top;
  final double bottom;

  const _ChartAxesPainter({
    required this.color,
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = AppSizes.chartAxisStroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(left, bottom), Offset(left, top), linePaint);
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), linePaint);

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final arrow = AppSizes.chartArrowSize;
    final yArrow = Path()
      ..moveTo(left, top - arrow)
      ..lineTo(left - arrow * 0.55, top + arrow * 0.55)
      ..lineTo(left + arrow * 0.55, top + arrow * 0.55)
      ..close();
    canvas.drawPath(yArrow, arrowPaint);

    final xArrow = Path()
      ..moveTo(right + arrow, bottom)
      ..lineTo(right - arrow * 0.55, bottom - arrow * 0.55)
      ..lineTo(right - arrow * 0.55, bottom + arrow * 0.55)
      ..close();
    canvas.drawPath(xArrow, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _ChartAxesPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.left != left ||
        oldDelegate.right != right ||
        oldDelegate.top != top ||
        oldDelegate.bottom != bottom;
  }
}
