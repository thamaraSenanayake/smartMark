import 'package:flutter/material.dart';
import '../constants/theme.dart';

class BellCurveWidget extends StatelessWidget {
  final Map<String, int> distribution;
  final double classAverage;

  const BellCurveWidget({
    super.key,
    required this.distribution,
    this.classAverage = 74.8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Grade Distribution (Standard Curve)",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryNavy,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.brandIndigo,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  "Bell Curve Fit",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: CustomPaint(
            size: Size.infinite,
            painter: _BellCurvePainter(distribution: distribution),
          ),
        ),
      ],
    );
  }
}

class _BellCurvePainter extends CustomPainter {
  final Map<String, int> distribution;

  _BellCurvePainter({required this.distribution});

  @override
  void paint(Canvas canvas, Size size) {
    final keys = distribution.keys.toList();
    final values = distribution.values.toList();
    final rawMax = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b).toDouble();
    final maxVal = rawMax == 0 ? 1.0 : rawMax;

    final barWidth = size.width / (keys.length * 1.6);
    final spacing = (size.width - (barWidth * keys.length)) / (keys.length + 1);

    final barPaint = Paint()
      ..color = AppColors.brandIndigoLight
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.brandIndigo.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final points = <Offset>[];

    for (int i = 0; i < keys.length; i++) {
      final x = spacing + i * (barWidth + spacing);
      final heightRatio = values[i] / (maxVal * 1.15);
      final barHeight = size.height * 0.75 * heightRatio;
      final y = (size.height * 0.78) - barHeight;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );

      // Draw bar
      canvas.drawRRect(rect, barPaint);
      canvas.drawRRect(rect, borderPaint);

      // Save center top for curve
      points.add(Offset(x + barWidth / 2, y));

      // Draw count text on top
      textPainter.text = TextSpan(
        text: "${values[i]}",
        style: const TextStyle(
          color: AppColors.primaryNavy,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, y - 16),
      );

      // Draw Grade label below
      final label = keys[i].split(' ')[0];
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, size.height * 0.82),
      );
    }

    // Draw baseline
    final linePaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, size.height * 0.78),
      Offset(size.width, size.height * 0.78),
      linePaint,
    );

    // Draw smooth bell curve
    if (points.isNotEmpty) {
      final curvePath = Path();
      curvePath.moveTo(0, size.height * 0.78);
      curvePath.quadraticBezierTo(
        points[0].dx / 2,
        size.height * 0.78,
        points[0].dx,
        points[0].dy,
      );

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final midX = (p0.dx + p1.dx) / 2;
        final midY = (p0.dy + p1.dy) / 2;
        curvePath.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
      }

      final last = points.last;
      curvePath.quadraticBezierTo(
        last.dx,
        last.dy,
        size.width,
        size.height * 0.78,
      );

      final curvePaint = Paint()
        ..color = AppColors.brandIndigo
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawPath(curvePath, curvePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
