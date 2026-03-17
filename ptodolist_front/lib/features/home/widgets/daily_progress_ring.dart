import 'package:flutter/material.dart';
import 'dart:math';

class DailyProgressRing extends StatelessWidget {
  final int completed;
  final int total;
  final double size;

  const DailyProgressRing({
    super.key,
    required this.completed,
    required this.total,
    this.size = 80,
  });

  double get _progress => total == 0 ? 0.0 : completed / total;
  int get _percent => (_progress * 100).round();

  Color _progressColor() {
    if (_progress >= 1.0) return const Color(0xFF10B981); // success
    if (_progress >= 0.5) return const Color(0xFF4F46E5); // primary
    return const Color(0xFFF59E0B); // warning
  }

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              progress: _progress,
              color: _progressColor(),
              trackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Text(
                '$_percent%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$completed/$total 완료',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;
    const strokeWidth = 8.0;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress
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
