import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../data/mock_data.dart';
import '../../models/assessment.dart';
import '../../widgets/custom_card.dart';
import 'm2_camera_viewfinder.dart';
import 'm4_batch_queue.dart';
import 'master_rubric_screen.dart';

class AssessmentHubScreen extends StatefulWidget {
  final VoidCallback? onSwitchToWeb;

  const AssessmentHubScreen({super.key, this.onSwitchToWeb});

  @override
  State<AssessmentHubScreen> createState() => _AssessmentHubScreenState();
}

class _AssessmentHubScreenState extends State<AssessmentHubScreen> {
  String selectedClass = MockData.availableClasses[0];
  String selectedRubric = MockData.availableRubrics[0];
  final ExamPaper exam = MockData.activeExam;

  @override
  Widget build(BuildContext context) {
    final scannedRatio = exam.scannedCount / exam.totalStudents;
    final remainingCount = exam.totalStudents - exam.scannedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.brandIndigo, size: 20),
            SizedBox(width: 8),
            Text("SmartMark"),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Batch Sync Queue",
            icon: const Badge(
              label: Text("3"),
              backgroundColor: AppColors.warningAmber,
              child: Icon(Icons.cloud_sync_outlined),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BatchQueueScreen()),
              );
            },
          ),
          if (widget.onSwitchToWeb != null)
            IconButton(
              tooltip: "Switch to Web Portal",
              icon: const Icon(Icons.dashboard_outlined),
              onPressed: widget.onSwitchToWeb,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class & Assessment Selector Card
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TARGET CLASS & SUBJECT",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.neutralCanvas,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedClass,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryNavy),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                        items: MockData.availableClasses.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedClass = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "ACTIVE MARKING RUBRIC",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.neutralCanvas,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRubric,
                        isExpanded: true,
                        icon: const Icon(Icons.tune, color: AppColors.brandIndigo, size: 18),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryNavy,
                        ),
                        items: MockData.availableRubrics.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedRubric = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Scan Progress KPI Banner
            CustomCard(
              backgroundColor: AppColors.cardBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "BATCH SCANNING PROGRESS",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryNavy,
                                letterSpacing: -0.5,
                              ),
                              children: [
                                TextSpan(text: "${exam.scannedCount}"),
                                TextSpan(
                                  text: " / ${exam.totalStudents} papers",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.brandIndigoLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${(scannedRatio * 100).toInt()}% Done",
                          style: const TextStyle(
                            color: AppColors.brandIndigo,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: scannedRatio,
                      backgroundColor: AppColors.borderLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandIndigo),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$remainingCount remaining in class bundle",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Text(
                        "Est. 4 min left",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions Section
            const Text(
              "QUICK ACTIONS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BatchQueueScreen()),
                      );
                    },
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.inventory_2_outlined, color: AppColors.brandIndigo),
                        SizedBox(height: 8),
                        Text(
                          "Offline Queue",
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        Text(
                          "3 pending sync",
                          style: TextStyle(color: AppColors.warningAmber, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MasterRubricSetupScreen()),
                      );
                    },
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.rule_outlined, color: AppColors.successGreen),
                        SizedBox(height: 8),
                        Text(
                          "Master Scheme",
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        Text(
                          "Calibrated v2.1",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Scanned Roster Snippet
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "RECENTLY SCANNED",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BatchQueueScreen()),
                    );
                  },
                  child: const Text("View All", style: TextStyle(fontSize: 12, color: AppColors.brandIndigo)),
                ),
              ],
            ),
            ...MockData.studentScans.take(3).map((scan) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: CustomCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.brandIndigoLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          scan.name.substring(0, 1),
                          style: const TextStyle(
                            color: AppColors.brandIndigo,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scan.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              scan.rollNumber,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${scan.totalScore.toStringAsFixed(0)} / 100",
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          Text(
                            "Grade ${scan.letterGrade}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: scan.letterGrade == 'A'
                                  ? AppColors.successGreen
                                  : AppColors.brandIndigo,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brandIndigo,
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text(
          "START SCANNER",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraViewfinderScreen()),
          );
        },
      ),
    );
  }
}
