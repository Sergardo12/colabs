import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class GoalGauge extends StatefulWidget {
  final int percent;

  const GoalGauge({super.key, required this.percent});

  @override
  State<GoalGauge> createState() => _GoalGaugeState();
}

class _GoalGaugeState extends State<GoalGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant GoalGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final percent = (_animation.value * widget.percent).round();
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _GoalGaugePainter(progress: _animation.value),
                ),
              ),
              Positioned(
                bottom: AppSizes.paddingS,
                child: Text(
                  '$percent%',
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: AppSizes.fontXXL,
                    fontWeight: FontWeight.bold,
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

class _GoalGaugePainter extends CustomPainter {
  final double progress;

  const _GoalGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = math.min(size.width, size.height) * 0.12;
    final radius = math.min(size.width / 2, size.height) - strokeWidth / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height),
      radius: radius,
    );

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppChartColors.gaugeTrack.withValues(alpha: 0.35);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppChartColors.gaugeProgress;

    canvas.drawArc(rect, math.pi, math.pi, false, trackPaint);
    if (progress > 0) {
      canvas.drawArc(rect, math.pi, math.pi * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoalGaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
