import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/assessment.dart';

class ExamOverlayWidget extends StatelessWidget {
  final String imagePath;
  final List<QuestionResult> questions;
  final Function(QuestionResult)? onQuestionTapped;

  const ExamOverlayWidget({
    super.key,
    required this.imagePath,
    required this.questions,
    this.onQuestionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Base scan image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMobile),
              child: Image.asset(
                imagePath,
                width: constraints.maxWidth,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 480,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Scanned Exam Paper View"),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Augmented CV Bounding Box Overlays
            Positioned.fill(
              child: CustomPaint(
                painter: _OverlayPainter(questions: questions),
              ),
            ),

            // Tap detector overlays for quick teacher override
            if (onQuestionTapped != null)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, innerConstraints) {
                    final w = innerConstraints.maxWidth;
                    final h = innerConstraints.maxHeight;

                    return Stack(
                      children: questions.map((q) {
                        final rect = q.boundingBox;
                        final left = rect.left * w;
                        final top = rect.top * h;
                        final width = rect.width * w;
                        final height = rect.height * h;

                        return Positioned(
                          left: left,
                          top: top,
                          width: width,
                          height: height,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => onQuestionTapped!(q),
                              borderRadius: BorderRadius.circular(4),
                              splashColor: (q.isCorrect
                                      ? AppColors.successGreen
                                      : AppColors.errorRose)
                                  .withOpacity(0.3),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final List<QuestionResult> questions;

  _OverlayPainter({required this.questions});

  @override
  void paint(Canvas canvas, Size size) {
    for (var q in questions) {
      final rect = Rect.fromLTWH(
        q.boundingBox.left * size.width,
        q.boundingBox.top * size.height,
        q.boundingBox.width * size.width,
        q.boundingBox.height * size.height,
      );

      final color = q.requiresAudit
          ? AppColors.warningAmber
          : (q.isCorrect ? AppColors.successGreen : AppColors.errorRose);

      // Bounding box outline
      final boxPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final fillPaint = Paint()
        ..color = color.withOpacity(0.12)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(rrect, fillPaint);
      canvas.drawRRect(rrect, boxPaint);

      // Indicator badge (Checkmark or Cross)
      final badgeRect = Rect.fromLTWH(rect.left - 6, rect.top - 6, 16, 16);
      final badgePaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(badgeRect.center, 8, badgePaint);

      final iconPainter = TextPainter(textDirection: TextDirection.ltr);
      iconPainter.text = TextSpan(
        text: q.isCorrect ? "✓" : "✗",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      );
      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(badgeRect.center.dx - iconPainter.width / 2,
            badgeRect.center.dy - iconPainter.height / 2),
      );

      // Score chip
      final scorePainter = TextPainter(textDirection: TextDirection.ltr);
      scorePainter.text = TextSpan(
        text: "+${q.pointsEarned.toStringAsFixed(0)}",
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          backgroundColor: Colors.white.withOpacity(0.85),
        ),
      );
      scorePainter.layout();
      scorePainter.paint(
        canvas,
        Offset(rect.right - scorePainter.width - 2, rect.top + 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
