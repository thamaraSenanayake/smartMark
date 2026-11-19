import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../widgets/custom_card.dart';
import 'm2_camera_viewfinder.dart';

class MasterRubricSetupScreen extends StatefulWidget {
  const MasterRubricSetupScreen({super.key});

  @override
  State<MasterRubricSetupScreen> createState() => _MasterRubricSetupScreenState();
}

class _MasterRubricSetupScreenState extends State<MasterRubricSetupScreen> {
  final Map<int, String> _mcqKey = {
    1: 'B',
    2: 'C',
    3: 'A',
    4: 'D',
    5: 'C',
    6: 'B',
    7: '420 J/kg·K (Open)',
    8: 'Ek = 1/2 mv² (Open)',
    9: 'A',
    10: 'C',
  };

  void _snapMasterSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CameraViewfinderScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Align master marking sheet. System will auto-calibrate answer bubbles."),
        backgroundColor: AppColors.brandIndigo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Marking Scheme Setup"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Save Rubric",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Marking Scheme v2.1 saved and calibrated."),
                  backgroundColor: AppColors.successGreen,
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Snap Master Sheet Banner
            CustomCard(
              backgroundColor: AppColors.brandIndigoLight,
              border: Border.all(color: AppColors.brandIndigo.withOpacity(0.3)),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.document_scanner, color: AppColors.brandIndigo),
                      SizedBox(width: 10),
                      Text(
                        "Auto-Calibrate via Camera",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Snap a physical master marking paper filled by the examiner. Computer Vision will auto-detect bubbles and configure the digital key.",
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandIndigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.camera_alt, size: 16),
                    label: const Text("Snap Master Marking Sheet"),
                    onPressed: _snapMasterSheet,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "ACTIVE RUBRIC KEY (SCIENCE TERM 1 - V2.1)",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            ..._mcqKey.entries.map((entry) {
              final qNum = entry.key;
              final answer = entry.value;
              final isOpenEnded = answer.contains('Open');

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: CustomCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.neutralCanvas,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Q$qNum",
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: isOpenEnded
                            ? Text(
                                "Rubric: $answer",
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              )
                            : Row(
                                children: ['A', 'B', 'C', 'D'].map((opt) {
                                  final isSelected = answer == opt;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() => _mcqKey[qNum] = opt);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? AppColors.brandIndigo : AppColors.neutralCanvas,
                                        border: Border.all(
                                          color: isSelected ? AppColors.brandIndigo : AppColors.borderLight,
                                        ),
                                      ),
                                      child: Text(
                                        opt,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : AppColors.textSecondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                      Text(
                        isOpenEnded ? "10 pts" : "5 pts",
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
