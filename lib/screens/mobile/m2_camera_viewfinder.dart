import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../data/mock_data.dart';
import 'm3_grading_overlay.dart';

class CameraViewfinderScreen extends StatefulWidget {
  const CameraViewfinderScreen({super.key});

  @override
  State<CameraViewfinderScreen> createState() => _CameraViewfinderScreenState();
}

class _CameraViewfinderScreenState extends State<CameraViewfinderScreen>
    with SingleTickerProviderStateMixin {
  bool isFlashOn = false;
  bool isBatchMode = true;
  bool isCornerStabilized = false;
  double lockProgress = 0.0;
  Timer? _stabilizationTimer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Simulate real-time contour lock
    _startSimulatedLock();
  }

  void _startSimulatedLock() {
    _stabilizationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        lockProgress += 0.05;
        if (lockProgress >= 1.0) {
          lockProgress = 1.0;
          isCornerStabilized = true;
          timer.cancel();

          // Auto-trigger capture after 600ms of stable lock
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              _triggerCapture();
            }
          });
        }
      });
    });
  }

  void _triggerCapture() {
    // Navigate to M3 Grading Review & Instant Overlay
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => InstantVerificationScreen(
          studentScan: MockData.studentScans[0], // Alex Perera's test paper
          isBatchMode: isBatchMode,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stabilizationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Simulated camera view with authentic test paper
          Center(
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.asset(
                "assets/images/science_exam_paper.jpg",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    alignment: Alignment.center,
                    child: const Icon(Icons.document_scanner, color: Colors.white30, size: 80),
                  );
                },
              ),
            ),
          ),

          // Dark camera viewfinder vignette
          Container(
            color: Colors.black.withOpacity(0.35),
          ),

          // 4-Corner OpenCV Guide Pins & Perspective Alignment Box
          CustomPaint(
            size: Size.infinite,
            painter: _CornerGuidePainter(
              progress: lockProgress,
              isStabilized: isCornerStabilized,
              pulse: _pulseController.value,
            ),
          ),

          // Top Camera Controls Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      // HUD Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCornerStabilized
                              ? AppColors.successGreen
                              : Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCornerStabilized
                                ? AppColors.successGreen
                                : Colors.white24,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCornerStabilized
                                  ? Icons.check_circle
                                  : Icons.center_focus_strong,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isCornerStabilized
                                  ? "ALIGNMENT LOCKED"
                                  : "HOLD STILL (${(lockProgress * 100).toInt()}%)",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: isFlashOn ? AppColors.warningAmber : Colors.white,
                          size: 26,
                        ),
                        onPressed: () {
                          setState(() => isFlashOn = !isFlashOn);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Mode Switcher (Single vs Batch)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildModeTab("Single", !isBatchMode, () {
                          setState(() => isBatchMode = false);
                        }),
                        _buildModeTab("Batch (Auto)", isBatchMode, () {
                          setState(() => isBatchMode = true);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Shutter & Guidance Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: SafeArea(
              child: Column(
                children: [
                  const Text(
                    "Align exam margins with 4 corner pins",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery / Test Paper Fallback
                      IconButton(
                        icon: const Icon(Icons.photo_library_outlined, color: Colors.white70, size: 28),
                        onPressed: () {
                          _triggerCapture();
                        },
                      ),
                      // Shutter Button
                      GestureDetector(
                        onTap: _triggerCapture,
                        child: Container(
                          width: 76,
                          height: 76,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCornerStabilized
                                  ? AppColors.successGreen
                                  : Colors.white,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.black87, size: 30),
                          ),
                        ),
                      ),
                      // Rubric Preview Shortcut
                      IconButton(
                        icon: const Icon(Icons.receipt_long_outlined, color: Colors.white70, size: 28),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Active: Science Term 1 Rubric v2.1")),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.brandIndigo : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CornerGuidePainter extends CustomPainter {
  final double progress;
  final bool isStabilized;
  final double pulse;

  _CornerGuidePainter({
    required this.progress,
    required this.isStabilized,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 4 Corner coordinates representing document bounding polygon
    final left = size.width * 0.10;
    final right = size.width * 0.90;
    final top = size.height * 0.18;
    final bottom = size.height * 0.78;

    final color = isStabilized ? AppColors.successGreen : AppColors.brandIndigo;

    // Corner guides length
    const len = 34.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = isStabilized ? 4.0 : 3.0
      ..style = PaintingStyle.stroke;

    // Top-Left
    canvas.drawLine(Offset(left, top), Offset(left + len, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + len), paint);

    // Top-Right
    canvas.drawLine(Offset(right, top), Offset(right - len, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + len), paint);

    // Bottom-Left
    canvas.drawLine(Offset(left, bottom), Offset(left + len, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - len), paint);

    // Bottom-Right
    canvas.drawLine(Offset(right, bottom), Offset(right - len, bottom), paint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - len), paint);

    // Guide Frame Outline
    final framePaint = Paint()
      ..color = color.withOpacity(isStabilized ? 0.35 : 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), framePaint);

    // Center Scanning Reticle
    final center = Offset(size.width / 2, (top + bottom) / 2);
    final reticlePaint = Paint()
      ..color = color.withOpacity(0.4)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(center.dx - 12, center.dy), Offset(center.dx + 12, center.dy), reticlePaint);
    canvas.drawLine(Offset(center.dx, center.dy - 12), Offset(center.dx, center.dy + 12), reticlePaint);
  }

  @override
  bool shouldRepaint(covariant _CornerGuidePainter oldDelegate) => true;
}
