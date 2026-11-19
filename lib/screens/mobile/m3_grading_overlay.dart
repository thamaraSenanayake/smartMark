import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../data/mock_data.dart';
import '../../models/assessment.dart';
import '../../widgets/exam_overlay_painter.dart';
import 'm2_camera_viewfinder.dart';

class InstantVerificationScreen extends StatefulWidget {
  final StudentExamScan studentScan;
  final bool isBatchMode;

  const InstantVerificationScreen({
    super.key,
    required this.studentScan,
    this.isBatchMode = true,
  });

  @override
  State<InstantVerificationScreen> createState() =>
      _InstantVerificationScreenState();
}

class _InstantVerificationScreenState extends State<InstantVerificationScreen> {
  late StudentExamScan scan;

  @override
  void initState() {
    super.initState();
    scan = widget.studentScan;
  }

  void _showOverrideModal(QuestionResult q) {
    double currentPoints = q.pointsEarned;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Override Score: Question ${q.questionNumber}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  Text(
                    "Topic: ${q.topic}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.neutralCanvas,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Detected Answer",
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            Text(
                              q.studentAnswer,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: q.isCorrect ? AppColors.successGreen : AppColors.errorRose,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "Key Answer",
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            Text(
                              q.correctAnswer,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Assign Points:",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove),
                        onPressed: currentPoints > 0
                            ? () {
                                setModalState(() {
                                  currentPoints = (currentPoints - 1.0).clamp(0.0, q.maxPoints);
                                });
                              }
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "${currentPoints.toStringAsFixed(0)} / ${q.maxPoints.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Courier',
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.add),
                        onPressed: currentPoints < q.maxPoints
                            ? () {
                                setModalState(() {
                                  currentPoints = (currentPoints + 1.0).clamp(0.0, q.maxPoints);
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandIndigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          q.overridePoints(currentPoints);
                          scan.recalculateScore();
                        });
                        Navigator.pop(modalContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Score updated for Q${q.questionNumber}: ${currentPoints.toStringAsFixed(0)} pts",
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "APPLY OVERRIDE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final correctCount = scan.questions.where((q) => q.isCorrect).length;
    final totalCount = scan.questions.length;

    return Scaffold(
      backgroundColor: AppColors.neutralCanvas,
      appBar: AppBar(
        title: const Text("Grading Verification"),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: "Tap any question box on the paper to override points",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tip: Tap any green/red box to override points.")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top HUD Card
          Container(
            padding: const EdgeInsets.all(14.0),
            color: AppColors.cardBg,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Student Identification
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.brandIndigoLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person, color: AppColors.brandIndigo, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scan.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  scan.rollNumber,
                                  style: const TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.successBackdrop,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "OCR Match 99.4%",
                                    style: TextStyle(
                                      color: AppColors.successGreen,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Total Score & Grade
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              scan.totalScore.toStringAsFixed(0),
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryNavy,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Text(
                              " / 100",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: scan.letterGrade == 'A'
                                ? AppColors.successBackdrop
                                : AppColors.brandIndigoLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "Grade ${scan.letterGrade} • Top ${(100 - scan.percentile).toStringAsFixed(0)}%",
                            style: TextStyle(
                              color: scan.letterGrade == 'A'
                                  ? AppColors.successGreen
                                  : AppColors.brandIndigo,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Question summary breakdown pills
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successBackdrop,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "✓ $correctCount Correct",
                        style: const TextStyle(
                          color: AppColors.successGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.errorBackdrop,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "✗ ${totalCount - correctCount} Mistake(s)",
                        style: const TextStyle(
                          color: AppColors.errorRose,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Tap box to edit",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // High-Res Warped Sheet with Augmented Overlays
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: ExamOverlayWidget(
                imagePath: scan.imagePath,
                questions: scan.questions,
                onQuestionTapped: (q) => _showOverrideModal(q),
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: AppColors.cardBg,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.errorRose,
                      side: const BorderSide(color: AppColors.errorBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Discard"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text(
                      "Save & Scan Next",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      if (!MockData.studentScans.any((s) => s.id == scan.id)) {
                        MockData.addScan(scan);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Saved ${scan.name} (${scan.totalScore.toStringAsFixed(0)}/100) to batch queue."),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                      if (widget.isBatchMode) {
                        // Auto-reopens camera in batch mode
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const CameraViewfinderScreen()),
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
