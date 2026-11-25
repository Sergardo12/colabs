import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../models/statistics_data.dart';
import '../../models/statistics_labels.dart';
import '../../models/statistics_period.dart';

class ServicesAreaChart extends StatelessWidget {
  final StatisticsData data;

  const ServicesAreaChart({super.key, required this.data});

  static const Color _lineColor = Color.fromARGB(255, 255, 136, 0);
  static const double _lineWidth = 3.0;
  static const double _dotRadius = 2.5;
  static const Color _gridColor = Color.fromARGB(30, 108, 92, 231);
  static const double _gridStroke = 1.0;
  static const double _axisEpsilon = 1e-6;

  @override
  Widget build(BuildContext context) {
    final interval = data.yAxisInterval.toDouble();
    final yAxisMax = data.yAxisMax.toDouble();
    final axisColor = AppChartColors.axis;
    final count = data.bars.length;
    final minX = -0.5;
    final maxX = count - 0.5;

    return SizedBox(
      height: AppSizes.chartHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final left = AppSizes.chartLeftInsetForMax(data.yAxisMax);
          final right = constraints.maxWidth - AppSizes.chartRightInset;
          final top = AppSizes.chartTopInset;
          final bottom = AppSizes.chartHeight - AppSizes.chartBottomInset;
          final lineLeft =
              left - AppSizes.chartLeftReserved + AppSizes.chartAxisStroke / 2;
          final lineRightInset =
              AppSizes.chartRightInset + AppSizes.chartAxisStroke / 2;
          final lineBottomInset =
              AppSizes.chartBottomInset - AppSizes.chartBottomReserved;

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
                left: lineLeft,
                right: lineRightInset,
                top: top,
                bottom: lineBottomInset,
                child: LineChart(
                  LineChartData(
                    minX: minX,
                    maxX: maxX,
                    minY: 0,
                    maxY: yAxisMax,
                    lineTouchData: const LineTouchData(enabled: false),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (_) => const FlLine(
                        color: _gridColor,
                        strokeWidth: _gridStroke,
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List<FlSpot>.generate(
                          count,
                          (index) => FlSpot(
                            index.toDouble(),
                            data.bars[index].value,
                          ),
                        ),
                        color: _lineColor,
                        barWidth: _lineWidth,
                        isCurved: true,
                        isStrokeCapRound: true,
                        isStrokeJoinRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (_, __, ___, ____) =>
                              FlDotCirclePainter(
                            radius: _dotRadius,
                            color: const Color.fromARGB(255, 255, 255, 255),
                            strokeWidth: 0,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              Color.fromARGB(255, 255, 136, 0),
                              Color.fromARGB(0, 0, 85, 255),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                              space: AppSizes.chartTitleSpace,
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
                            if ((value - index).abs() > _axisEpsilon ||
                                index < 0 ||
                                index >= data.bars.length) {
                              return const SizedBox.shrink();
                            }
                            final isDays = data.period == StatisticsPeriod.days;
                            final label = isDays
                                ? StatisticsLabels.weekdayInitials[(data
                                              .bars[index]
                                              .key -
                                          1)
                                      .clamp(
                                        0,
                                        StatisticsLabels
                                                .weekdayInitials
                                                .length -
                                            1,
                                      )]
                                : StatisticsLabels.forBar(
                                    data.bars[index].key,
                                    data.period,
                                  );
                            return SideTitleWidget(
                              meta: meta,
                              space: AppSizes.chartTitleSpace,
                              angle: isDays ? 0 : AppSizes.chartMonthLabelAngle,
                              fitInside: isDays
                                  ? SideTitleFitInsideData.disable()
                                  : SideTitleFitInsideData.fromTitleMeta(
                                      meta,
                                      distanceFromEdge:
                                          AppSizes.chartTitleSpace,
                                    ),
                              child: Text(
                                label,
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
