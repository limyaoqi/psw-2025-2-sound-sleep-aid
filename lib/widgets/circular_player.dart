import 'dart:math' as math;

import 'package:flutter/material.dart';

class CircularPlayer extends StatelessWidget {
  final double size;
  final Widget child;
  final double progress; // 0.0 - 1.0 (UI only)

  const CircularPlayer({
    super.key,
    this.size = 320,
    required this.child,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // outer progress ring + background
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(progress: progress, color: accent),
          ),

          // subtle halo behind vinyl to echo control button styling
          Container(
            width: size * 0.98,
            height: size * 0.98,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  accent.withOpacity(0.08),
                  accent.withOpacity(0.02),
                  accent.withOpacity(0.08),
                ],
              ),
            ),
          ),

          // vinyl disc with subtle grooves (larger)
          Container(
            width: size * 0.92,
            height: size * 0.92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.black, Colors.grey.shade900],
                center: const Alignment(-0.2, -0.2),
                stops: const [0.0, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _GroovePainter(),
              child: Center(
                child: Container(
                  width: size * 0.14,
                  height: size * 0.14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade800,
                    border: Border.all(color: Colors.grey.shade700, width: 2),
                  ),
                ),
              ),
            ),
          ),

          // center child (e.g., album title) placed above the disc center
          SizedBox(width: size * 0.68, child: child),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    // even thinner progress ring for a refined, delicate look
    final ringWidth = size.width * 0.025;

    // background ring
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringWidth
      ..color = Colors.grey.shade300.withOpacity(0.4)
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(center, outerRadius - ringWidth / 2 - 4, bgPaint);

    // progress arc (start at -90deg -> 12 o'clock)
    if (progress > 0) {
      final rect = Rect.fromCircle(
        center: center,
        radius: outerRadius - ringWidth / 2 - 4,
      );
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + 2 * math.pi * progress,
          colors: [color, color.withOpacity(0.6)],
        ).createShader(rect);

      // draw arc by rotating canvas so sweep gradient aligns from 12 o'clock
      canvas.save();
      // draw full sweep using drawArc but limit sweep to progress angle
      final sweep = 2 * math.pi * progress;
      canvas.drawArc(rect, -math.pi / 2, sweep, false, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _GroovePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;

    // draw subtle concentric circles to simulate grooves
    for (double r = maxR * 0.9; r > maxR * 0.18; r -= maxR * 0.018) {
      paint.color = Colors.white.withOpacity(0.02 + (maxR - r) / maxR * 0.01);
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
