import 'dart:math' as math;

class AppSizes {
  AppSizes._();

  // Padding y margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Botones
  static const double buttonHeight = 56.0;

  // Inputs
  static const double inputHeight = 56.0;
  static const double inputMedianHeight = 48.0;
  static const double inputSmallHeight = 36.0;

  // Font sizes
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 20.0;
  static const double fontXXL = 28.0;
  static const double fontXXXL = 32.0;
  static const double headerTitleFont = 22.0;

  // Statistics
  static const double periodButtonWidth = 88.0;
  static const double periodButtonHeight = 34.0;
  static const double chartHeight = 280.0;
  static const double chartAxisStroke = 2.0;
  static const double chartArrowSize = 10.0;
  static const double chartLeftInset = 46.0;
  static const double chartRightInset = 52.0;
  static const double chartTopInset = 26.0;
  static const double chartBottomInset   = 30.0;
  static const double chartLeftReserved = 28.0;
  static const double chartBottomReserved = 30.0;
  static const double chartTitleSpace = 8.0;
  static const double chartMonthLabelAngle = -0.9;
  static const double chartDigitWidth = 7.0;
  static const double chartRodMinWidth = 12.0;
  static const double chartRodMaxWidth = 30.0;
  static const double chartRodGap = 2.0;
  static const double chartRodRadius = 4.0;
  static const double pieSize = 110.0;
  static const double pieRadius = 52.0;
  static const double goalImageSize = 90.0;

  static double chartLeftInsetForMax(int yAxisMax) {
    final extraDigits = (yAxisMax.toString().length - 3).clamp(0, 3);
    return chartLeftInset + extraDigits * chartDigitWidth;
  }

  static double chartRodWidth({
    required int barCount,
    required double chartWidth,
    required int yAxisMax,
  }) {
    if (barCount <= 0) return chartRodMinWidth;
    final barsLeft =
        chartLeftInsetForMax(yAxisMax) -
        chartLeftReserved +
        chartAxisStroke / 2;
    final plotRight = chartWidth - chartRightInset - chartAxisStroke / 2;
    final plotWidth = plotRight - barsLeft - chartLeftReserved;
    final availableWidth = plotWidth / barCount;
    final preferredWidth = (180 / barCount)
        .clamp(chartRodMinWidth, chartRodMaxWidth)
        .toDouble();
    return math.max(
      1.0,
      math.min(preferredWidth, availableWidth - chartRodGap),
    );
  }
}
