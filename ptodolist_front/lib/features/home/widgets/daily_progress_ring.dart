import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:ptodolist/core/theme/app_theme.dart';

class DailyProgressRing extends StatelessWidget {
  final int completed;
  final int total;
  final double size;
  final bool compact;

  const DailyProgressRing({
    super.key,
    required this.completed,
    required this.total,
    this.size = 140,
    this.compact = false,
  });

  double get _progress => total == 0 ? 0.0 : completed / total;
  int get _percent => (_progress * 100).round();

  Color _progressColor(ColorScheme colorScheme) {
    if (_progress >= 1.0) return colorScheme.primary;
    if (_progress >= 0.5) return colorScheme.primary;
    return AppTheme.tertiary;
  }

  @override
  Widget build(BuildContext context) {
    if (total == 0) return SizedBox(width: size, height: size);

    final theme = Theme.of(context);
    final color = _progressColor(theme.colorScheme);
    final trackColor = theme.colorScheme.surfaceContainerHigh;
    final strokeWidth = compact ? 4.0 : 8.0;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: _progress,
          color: color,
          trackColor: trackColor,
          strokeWidth: strokeWidth,
        ),
        child: compact
            ? const SizedBox.shrink()
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_percent%',
                      style: GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'DONE',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
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
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    this.strokeWidth = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth - 4) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

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
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
