import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../data/mock_data.dart';
import '../../widgets/bell_curve_painter.dart';
import '../../widgets/custom_card.dart';

class ExecutiveDashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToQuestions;
  final VoidCallback onNavigateToGradebook;

  const ExecutiveDashboardScreen({
    super.key,
    required this.onNavigateToQuestions,
    required this.onNavigateToGradebook,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Export Actions
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Executive Assessment Overview",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Grade 10-A • Science Term 1 Assessment (Rubric v2.1)",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusWeb)),
                    ),
                    icon: const Icon(Icons.table_chart_outlined, size: 16),
                    label: const Text("Export CSV"),
                    onPressed: () {
                      _showCsvExportDialog(context);
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusWeb)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                    label: const Text("Generate Report Cards PDF"),
                    onPressed: () {
                      _showPdfReportDialog(context);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4 High-Level KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 760;
              final hasScans = MockData.studentScans.isNotEmpty;

              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isWide ? 1.35 : 1.25,
                children: [
                  _buildKpiCard(
                    title: "CLASS AVERAGE",
                    value: hasScans ? "${MockData.classAverage.toStringAsFixed(1)}%" : "N/A",
                    subtext: hasScans ? "Calculated from ${MockData.scannedCount} papers" : "No papers marked yet",
                    subColor: hasScans ? AppColors.successGreen : AppColors.textSecondary,
                    icon: Icons.trending_up,
                  ),
                  _buildKpiCard(
                    title: "TOP SCORE",
                    value: hasScans ? "${MockData.topScore.toStringAsFixed(1)}%" : "N/A",
                    subtext: hasScans ? "${MockData.studentScans.first.name} (${MockData.studentScans.first.rollNumber})" : "Awaiting scan",
                    subColor: AppColors.textSecondary,
                    icon: Icons.emoji_events_outlined,
                  ),
                  _buildKpiCard(
                    title: "PASSING RATE",
                    value: hasScans ? "${MockData.passingRate.toStringAsFixed(1)}%" : "N/A",
                    subtext: "Passing threshold ≥ 40%",
                    subColor: AppColors.brandIndigo,
                    icon: Icons.verified_outlined,
                  ),
                  _buildKpiCard(
                    title: "PAPERS MARKED",
                    value: "${MockData.scannedCount} / ${MockData.activeExam.totalStudents}",
                    subtext: "${((MockData.scannedCount / MockData.activeExam.totalStudents) * 100).toInt()}% Bundle Complete",
                    subColor: AppColors.warningAmber,
                    icon: Icons.assignment_turned_in_outlined,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Main Analytic Visualizations: Bell Curve & Blind-Spot Callout
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: CustomCard(
                            borderRadius: AppTheme.radiusWeb,
                            padding: const EdgeInsets.all(20),
                            child: BellCurveWidget(
                              distribution: MockData.gradeDistribution,
                              classAverage: 74.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildBlindSpotSummary(context),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        CustomCard(
                          borderRadius: AppTheme.radiusWeb,
                          padding: const EdgeInsets.all(20),
                          child: BellCurveWidget(
                            distribution: MockData.gradeDistribution,
                            classAverage: 74.8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBlindSpotSummary(context),
                      ],
                    );
            },
          ),
          const SizedBox(height: 24),

          // Chronological Batch History Table
          CustomCard(
            borderRadius: AppTheme.radiusWeb,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Chronological Batch Audit Log",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_forward, size: 14),
                      label: const Text("Open Full Gradebook"),
                      onPressed: onNavigateToGradebook,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (MockData.studentScans.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary, size: 36),
                          SizedBox(height: 8),
                          Text("No papers marked yet", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          SizedBox(height: 4),
                          Text("Papers scanned with the teacher camera will automatically synchronize here.", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 580),
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1.5),
                          2: FlexColumnWidth(1.2),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(1.5),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("STUDENT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("INDEX ID", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("SCORE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("GRADE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text("TIMESTAMP", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                              ),
                            ],
                          ),
                          ...MockData.studentScans.take(5).map((s) {
                            return TableRow(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primaryNavy)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(s.rollNumber, style: const TextStyle(fontFamily: 'Courier', fontSize: 12, color: AppColors.textSecondary)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text("${s.totalScore.toStringAsFixed(0)} / 100", style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.w700, fontSize: 13)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(s.letterGrade, style: TextStyle(fontWeight: FontWeight.w800, color: s.letterGrade == 'A' ? AppColors.successGreen : AppColors.brandIndigo)),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text("Just now", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtext,
    required Color subColor,
    required IconData icon,
  }) {
    return CustomCard(
      borderRadius: AppTheme.radiusWeb,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: AppColors.brandIndigo),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'Courier',
                color: AppColors.primaryNavy,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: subColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBlindSpotSummary(BuildContext context) {
    final blindSpots = MockData.itemAnalytics.where((i) => i.isBlindSpot).toList();
    final hasBlindSpot = blindSpots.isNotEmpty;

    return CustomCard(
      borderRadius: AppTheme.radiusWeb,
      backgroundColor: hasBlindSpot ? AppColors.errorBackdrop : AppColors.cardBg,
      border: Border.all(color: hasBlindSpot ? AppColors.errorBorder : AppColors.borderLight),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasBlindSpot ? Icons.report_problem_outlined : Icons.check_circle_outline,
                color: hasBlindSpot ? AppColors.errorRose : AppColors.successGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                hasBlindSpot ? "Curriculum Blind-Spot Alert" : "Curriculum Assessment Status",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: hasBlindSpot ? AppColors.errorRose : AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasBlindSpot
                ? "Question ${blindSpots.first.questionNumber} (${blindSpots.first.topic}) was failed by ${blindSpots.first.incorrectPercentage.toStringAsFixed(0)}% of students."
                : (MockData.studentScans.isEmpty
                    ? "Awaiting scanned papers to identify concept blind spots."
                    : "No critical blind spots detected. Passing rate standard met."),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasBlindSpot
                ? "Common error: ${blindSpots.first.commonMistake}. Recommendation: Revisit concept derivation before term exam."
                : (MockData.studentScans.isEmpty
                    ? "Use the mobile camera scanner to mark answer sheets. Analytics compute dynamically in real time."
                    : "All tested concepts met the standard ≥50% passing criteria."),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: hasBlindSpot ? AppColors.errorRose : AppColors.brandIndigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: onNavigateToQuestions,
            child: const Text("Inspect Item Analytics", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showCsvExportDialog(BuildContext context) {
    final csvContent = StringBuffer();
    csvContent.writeln("RollNumber,StudentName,Subject,TotalScore,MaxScore,Percentage,Grade,Percentile,SyncStatus");
    for (var s in MockData.studentScans) {
      csvContent.writeln(
        "${s.rollNumber},\"${s.name}\",\"${s.subject}\",${s.totalScore},${s.maxScore},${(s.totalScore / s.maxScore * 100).toStringAsFixed(1)}%,${s.letterGrade},Top ${(100 - s.percentile).toStringAsFixed(0)}%,${s.syncStatus.name}",
      );
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Row(
            children: [
              Icon(Icons.table_chart_outlined, color: AppColors.brandIndigo),
              SizedBox(width: 10),
              Text("CSV Gradebook Export Ready"),
            ],
          ),
          content: SizedBox(
            width: 580,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Export generated for Grade 10-A Science Assessment (45 records):",
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutralCanvas,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      csvContent.toString(),
                      style: const TextStyle(fontFamily: 'Courier', fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close"),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandIndigo,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.download, size: 16),
              label: const Text("Download .CSV"),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Gradebook downloaded: Grade10A_Science_Scores.csv"),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showPdfReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.cardBg,
          title: const Row(
            children: [
              Icon(Icons.picture_as_pdf, color: AppColors.errorRose),
              SizedBox(width: 10),
              Text("Automated PDF Report Cards"),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "SmartMark has batch-generated 45 individual PDF report cards with QR-verified scan thumbnails, itemized rubrics, and percentile rankings.",
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutralCanvas,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Student Sample:", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          Text("Alex Perera (SCI-1049)", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Subject & Exam:", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          Text("Science Term 1 Assessment", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Final Result:", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          Text("82 / 100 • Grade A (Top 12%)", style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.successGreen)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close"),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandIndigo,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.print_outlined, size: 16),
              label: const Text("Batch Print / Download All"),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Bundle exported: 45 Report Cards compiled into PDF archive."),
                    backgroundColor: AppColors.successGreen,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
