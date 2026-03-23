import 'package:flutter/material.dart';
import 'dart:math';
import 'package:ptodolist/core/theme/app_theme.dart';

class DailyProgressRing extends StatelessWidget {
  final int completed;
  final int total;
  final double size;

  const DailyProgressRing({
    super.key,
    required this.completed,
    required this.total,
    this.size = 140,
  });

  double get _progress => total == 0 ? 0.0 : completed / total;
  int get _percent => (_progress * 100).round();

  Color _progressColor() {
    if (_progress >= 1.0) return AppTheme.success;
    if (_progress >= 0.5) return AppTheme.primary;
    return AppTheme.warning;
  }

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    final color = _progressColor();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size + 32,
      height: size + 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: isDark ? 0.12 : 0.08),
            Colors.transparent,
          ],
          stops: const [0.5, 1.0],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              progress: _progress,
              color: color,
              trackColor: isDark ? AppTheme.darkCard : const Color(0xFFE5E7EB),
              glowColor: color.withValues(alpha: 0.3),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_percent%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: -1,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed/$total',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;
  final Color glowColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 14) / 2;
    const strokeWidth = 10.0;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Glow
    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      glowPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
