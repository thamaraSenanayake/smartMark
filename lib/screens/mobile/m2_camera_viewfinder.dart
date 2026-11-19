import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  String? _cameraErrorMessage;
  bool _isCapturing = false;

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

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _cameraErrorMessage = "No cameras detected on this device.";
        });
        return;
      }

      // Select back / rear camera for document scanning
      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
        _cameraErrorMessage = null;
      });

      _startContourLock();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraErrorMessage = "Camera access error: $e";
      });
    }
  }

  void _startContourLock() {
    _stabilizationTimer?.cancel();
    _stabilizationTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) return;
      setState(() {
        lockProgress += 0.08;
        if (lockProgress >= 1.0) {
          lockProgress = 1.0;
          isCornerStabilized = true;
          timer.cancel();

          // Auto-trigger capture in batch mode when 4 corners stabilize
          if (isBatchMode) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted && !_isCapturing) {
                _triggerCapture();
              }
            });
          }
        }
      });
    });
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;
    try {
      final nextState = !isFlashOn;
      await _cameraController!.setFlashMode(
        nextState ? FlashMode.torch : FlashMode.off,
      );
      setState(() => isFlashOn = nextState);
    } catch (_) {}
  }

  Future<void> _triggerCapture() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    String? capturedPath;

    // 1. Try real camera capture
    if (_cameraController != null && _isCameraInitialized) {
      try {
        final XFile photo = await _cameraController!.takePicture();
        capturedPath = photo.path;
      } catch (e) {
        debugPrint("Camera capture error: $e");
      }
    }

    // 2. If camera not available (e.g. desktop/simulator without camera permission), allow picking image
    if (capturedPath == null || capturedPath.isEmpty) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          capturedPath = image.path;
        }
      } catch (e) {
        debugPrint("Image picker error: $e");
      }
    }

    if (capturedPath != null && capturedPath.isNotEmpty) {
      // Create real scan entry
      final realScan = MockData.createScanFromCamera(imagePath: capturedPath);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InstantVerificationScreen(
            studentScan: realScan,
            isBatchMode: isBatchMode,
          ),
        ),
      );
    } else {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final realScan = MockData.createScanFromCamera(imagePath: image.path);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => InstantVerificationScreen(
            studentScan: realScan,
            isBatchMode: isBatchMode,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _stabilizationTimer?.cancel();
    _cameraController?.dispose();
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
          // Live Real Camera Feed
          if (_isCameraInitialized && _cameraController != null)
            Center(
              child: CameraPreview(_cameraController!),
            )
          else if (_cameraErrorMessage != null)
            _buildCameraFallback()
          else
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.brandIndigo),
                  SizedBox(height: 16),
                  Text(
                    "Connecting to optical camera feed...",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

          // 4-Corner OpenCV ML Guide Pins
          if (_isCameraInitialized)
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
                        onPressed: _toggleFlash,
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
                    "Point camera at student answer sheet",
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
                      // Import / Pick from gallery fallback
                      IconButton(
                        tooltip: "Import photo",
                        icon: const Icon(Icons.photo_library_outlined, color: Colors.white70, size: 28),
                        onPressed: _pickFromGallery,
                      ),
                      // Shutter Button
                      GestureDetector(
                        onTap: _isCapturing ? null : _triggerCapture,
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
                            child: _isCapturing
                                ? const Center(
                                    child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.brandIndigo),
                                  )
                                : const Icon(Icons.camera_alt, color: Colors.black87, size: 30),
                          ),
                        ),
                      ),
                      // Active rubric indicator
                      IconButton(
                        tooltip: "Active rubric key",
                        icon: const Icon(Icons.rule, color: Colors.white70, size: 28),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Grading against Rubric v2.1 (10 Questions - 100 Pts)"),
                              backgroundColor: AppColors.brandIndigo,
                            ),
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

  Widget _buildCameraFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 56),
            const SizedBox(height: 16),
            const Text(
              "Camera Not Available",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              _cameraErrorMessage ?? "Camera permission required to scan student papers.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandIndigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.photo_library),
              label: const Text("Select Sheet Photo from Gallery"),
              onPressed: _pickFromGallery,
            ),
          ],
        ),
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
    final left = size.width * 0.10;
    final right = size.width * 0.90;
    final top = size.height * 0.18;
    final bottom = size.height * 0.78;

    final color = isStabilized ? AppColors.successGreen : AppColors.brandIndigo;

    const len = 34.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = isStabilized ? 4.0 : 3.0
      ..style = PaintingStyle.stroke;

    // 4 Corners
    canvas.drawLine(Offset(left, top), Offset(left + len, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left, top + len), paint);

    canvas.drawLine(Offset(right, top), Offset(right - len, top), paint);
    canvas.drawLine(Offset(right, top), Offset(right, top + len), paint);

    canvas.drawLine(Offset(left, bottom), Offset(left + len, bottom), paint);
    canvas.drawLine(Offset(left, bottom), Offset(left, bottom - len), paint);

    canvas.drawLine(Offset(right, bottom), Offset(right - len, bottom), paint);
    canvas.drawLine(Offset(right, bottom), Offset(right, bottom - len), paint);

    final framePaint = Paint()
      ..color = color.withOpacity(isStabilized ? 0.35 : 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), framePaint);

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
