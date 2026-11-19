import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../data/mock_data.dart';
import '../../models/assessment.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/exam_overlay_painter.dart';

class StudentGradebookScreen extends StatefulWidget {
  const StudentGradebookScreen({super.key});

  @override
  State<StudentGradebookScreen> createState() => _StudentGradebookScreenState();
}

class _StudentGradebookScreenState extends State<StudentGradebookScreen> {
  String searchQuery = "";
  String gradeFilter = "All";
  StudentExamScan? selectedStudent;

  @override
  Widget build(BuildContext context) {
    List<StudentExamScan> students = MockData.studentScans;

    if (searchQuery.isNotEmpty) {
      students = students.where((s) {
        return s.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            s.rollNumber.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    if (gradeFilter != "All") {
      students = students.where((s) => s.letterGrade == gradeFilter).toList();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSplit = selectedStudent != null && constraints.maxWidth > 900;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Gradebook Table
            Expanded(
              flex: isSplit ? 3 : 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header & Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Student Roster & Gradebook",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryNavy,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Audit raw scan contours, OCR student IDs, and score breakdowns",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandIndigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusWeb)),
                          ),
                          icon: const Icon(Icons.file_download_outlined, size: 16),
                          label: const Text("Export Gradebook"),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Exporting gradebook to CSV...")),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Search & Filter Bar
                    CustomCard(
                      borderRadius: AppTheme.radiusWeb,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: "Search student name or index roll number...",
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) => setState(() => searchQuery = val),
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: gradeFilter,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryNavy,
                              ),
                              items: ["All", "A", "B", "C", "S", "F"].map((g) {
                                return DropdownMenuItem(
                                  value: g,
                                  child: Text("Grade: $g"),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => gradeFilter = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Table
                    CustomCard(
                      borderRadius: AppTheme.radiusWeb,
                      padding: const EdgeInsets.all(0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusWeb),
                        child: DataTable(
                          showCheckboxColumn: false,
                          headingRowColor: WidgetStateProperty.all(AppColors.neutralCanvas),
                          columns: const [
                            DataColumn(label: Text("STUDENT", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
                            DataColumn(label: Text("INDEX NUMBER", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
                            DataColumn(label: Text("SCORE", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
                            DataColumn(label: Text("GRADE", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
                            DataColumn(label: Text("PERCENTILE", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
                            DataColumn(label: Text("STATUS", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
                            DataColumn(label: Text("ACTION", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.textSecondary))),
                          ],
                          rows: students.map((s) {
                            final isSelected = selectedStudent?.id == s.id;
                            return DataRow(
                              selected: isSelected,
                              onSelectChanged: (_) {
                                setState(() {
                                  selectedStudent = isSelected ? null : s;
                                });
                              },
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: AppColors.brandIndigoLight,
                                        child: Text(
                                          s.name[0],
                                          style: const TextStyle(
                                            color: AppColors.brandIndigo,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    ],
                                  ),
                                ),
                                DataCell(Text(s.rollNumber, style: const TextStyle(fontFamily: 'Courier', fontSize: 12))),
                                DataCell(Text("${s.totalScore.toStringAsFixed(0)} / 100", style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.w800))),
                                DataCell(GradeBadge(grade: s.letterGrade)),
                                DataCell(Text("Top ${(100 - s.percentile).toStringAsFixed(0)}%", style: const TextStyle(fontSize: 12))),
                                DataCell(StatusPill(status: s.syncStatus)),
                                DataCell(
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      side: const BorderSide(color: AppColors.borderLight),
                                    ),
                                    onPressed: () {
                                      setState(() => selectedStudent = s);
                                      if (constraints.maxWidth <= 900) {
                                        _showAuditDialog(context, s);
                                      }
                                    },
                                    child: const Text("Audit Scan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Split-Screen Slide-Over Audit Drawer (when wide screen)
            if (isSplit && selectedStudent != null)
              Container(
                width: 440,
                decoration: const BoxDecoration(
                  color: AppColors.cardBg,
                  border: Border(left: BorderSide(color: AppColors.borderLight)),
                ),
                child: _buildAuditInspectionPanel(selectedStudent!),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAuditInspectionPanel(StudentExamScan student) {
    return Column(
      children: [
        // Panel Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  Text(
                    "${student.rollNumber} • ${student.gradeClass}",
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => selectedStudent = null),
              ),
            ],
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Augmented Exam Paper Scan
                const Text(
                  "AUGMENTED CV SCAN & ANNOTATIONS",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                ExamOverlayWidget(
                  imagePath: student.imagePath,
                  questions: student.questions,
                ),
                const SizedBox(height: 16),

                // Audit Notes
                const Text(
                  "TEACHER AUDIT LOG",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutralCanvas,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    student.auditNotes ?? "No manual overrides or audit notes recorded for this student.",
                    style: const TextStyle(fontSize: 12, color: AppColors.primaryNavy),
                  ),
                ),
                const SizedBox(height: 16),

                // Question breakdown chips
                const Text(
                  "QUESTION BREAKDOWN",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                ...student.questions.map((q) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: q.isCorrect ? AppColors.successBackdrop : AppColors.errorBackdrop,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: q.isCorrect ? AppColors.successBorder : AppColors.errorBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Q${q.questionNumber}: ${q.topic}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: q.isCorrect ? AppColors.successGreen : AppColors.errorRose,
                          ),
                        ),
                        Text(
                          "${q.pointsEarned.toStringAsFixed(0)} / ${q.maxPoints.toStringAsFixed(0)} pts",
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAuditDialog(BuildContext context, StudentExamScan student) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.cardBg,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            width: 500,
            height: 600,
            child: _buildAuditInspectionPanel(student),
          ),
        );
      },
    );
  }
}
