import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colabs_frontend/core/constants/app_colors.dart';
import 'package:colabs_frontend/features/statistics/pages/widgets/goal_gauge.dart';

void main() {
  group('goalGaugeSweepAngle', () {
    test('calcula y recorta el barrido del arco', () {
      expect(goalGaugeSweepAngle(0), 0);
      expect(goalGaugeSweepAngle(20), closeTo(math.pi / 5, 1e-12));
      expect(goalGaugeSweepAngle(100), closeTo(math.pi, 1e-12));
      expect(goalGaugeSweepAngle(140), closeTo(math.pi, 1e-12));
      expect(goalGaugeSweepAngle(-10), 0);
    });
  });

  test('los colores del gauge son distintos', () {
    expect(AppChartColors.gaugeProgress, isNot(AppChartColors.gaugeTrack));
    expect(AppChartColors.gaugeProgress, const Color(0xFFE53935));
    expect(AppChartColors.gaugeTrack, const Color(0xFF6FA8FF));
  });

  testWidgets('GoalGauge renderiza 0, 1, 20 y 100 por ciento', (tester) async {
    for (final percent in <int>[0, 1, 20, 100]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                child: GoalGauge(key: ValueKey<int>(percent), percent: percent),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('$percent%'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    }

    expect(tester.takeException(), isNull);
  });
}
