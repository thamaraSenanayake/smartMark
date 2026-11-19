import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../widgets/custom_card.dart';

class RubricManagerScreen extends StatefulWidget {
  const RubricManagerScreen({super.key});

  @override
  State<RubricManagerScreen> createState() => _RubricManagerScreenState();
}

class _RubricManagerScreenState extends State<RubricManagerScreen> {
  String selectedRubricVersion = "Rubric v2.1 (Active)";

  final List<Map<String, dynamic>> _rubricItems = [
    {
      "q": 1,
      "type": "MCQ",
      "topic": "Newton's First Law (Inertia)",
      "key": "B",
      "points": 5.0,
      "coords": "X: 12%, Y: 22%, W: 36%, H: 4.5%",
      "steps": "Single bubble select (Option B)"
    },
    {
      "q": 2,
      "type": "MCQ",
      "topic": "Velocity-Time Acceleration",
      "key": "C",
      "points": 5.0,
      "coords": "X: 12%, Y: 28%, W: 36%, H: 4.5%",
      "steps": "Single bubble select (Option C)"
    },
    {
      "q": 3,
      "type": "MCQ",
      "topic": "Ohm's Law Calculation (V=IR)",
      "key": "A",
      "points": 5.0,
      "coords": "X: 12%, Y: 34%, W: 36%, H: 4.5%",
      "steps": "Single bubble select (Option A)"
    },
    {
      "q": 4,
      "type": "MCQ",
      "topic": "Series Resistance",
      "key": "D",
      "points": 5.0,
      "coords": "X: 12%, Y: 40%, W: 36%, H: 4.5%",
      "steps": "Single bubble select (Option D)"
    },
    {
      "q": 5,
      "type": "MCQ",
      "topic": "Refraction Index of Glass",
      "key": "C",
      "points": 5.0,
      "coords": "X: 12%, Y: 46%, W: 36%, H: 4.5%",
      "steps": "Single bubble select (Option C)"
    },
    {
      "q": 6,
      "type": "Open-Ended",
      "topic": "Conservation of Momentum",
      "key": "m1u1 + m2u2 = (m1+m2)v",
      "points": 10.0,
      "coords": "X: 12%, Y: 53%, W: 76%, H: 6.0%",
      "steps": "Step 1: Formula [3 pts] • Step 2: Substitution [4 pts] • Step 3: Final Value with Units [3 pts]"
    },
    {
      "q": 7,
      "type": "Open-Ended",
      "topic": "Thermodynamics & Heat Capacity",
      "key": "c = Q / (mΔT) = 420 J/kg·K",
      "points": 10.0,
      "coords": "X: 12%, Y: 61%, W: 76%, H: 8.0%",
      "steps": "Step 1: Q=mcΔT isolate 'c' [3 pts] • Step 2: Substitution [4 pts] • Step 3: Calculation & Unit [3 pts]"
    },
    {
      "q": 8,
      "type": "Open-Ended",
      "topic": "Kinetic Energy Derivation",
      "key": "Ek = 1/2 mv²",
      "points": 10.0,
      "coords": "X: 12%, Y: 71%, W: 76%, H: 7.0%",
      "steps": "Step 1: Work-energy relation [4 pts] • Step 2: Integration/substitution [6 pts]"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Deploy Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Marking Scheme & Rubric Manager",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Digital Key Creator: MCQ Bubble Coordinate Mapping & Open-Ended Point Rubrics",
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Wrap(
                spacing: 12,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusWeb)),
                    ),
                    icon: const Icon(Icons.file_upload_outlined, size: 16),
                    label: const Text("Import Master Sheet Scan"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Master sheet imported and OCR coordinates aligned.")),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusWeb)),
                    ),
                    icon: const Icon(Icons.cloud_done_outlined, size: 16),
                    label: const Text("Deploy Rubric v2.2"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Rubric v2.2 successfully deployed to teacher scanner mobile app."),
                          backgroundColor: AppColors.successGreen,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Digital Rubric Configuration Table
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
                      "Configured Questions & Coordinate Anchors",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successBackdrop,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.successBorder),
                      ),
                      child: const Text(
                        "Total Points: 100.0 pts (15 Questions)",
                        style: TextStyle(
                          color: AppColors.successGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 780),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1.2),
                        2: FlexColumnWidth(2.5),
                        3: FlexColumnWidth(2),
                        4: FlexColumnWidth(1),
                        5: FlexColumnWidth(3),
                      },
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text("Q#", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text("TYPE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text("TOPIC / OUTCOME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text("CORRECT KEY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text("POINTS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text("OMR COORDINATES / STEP RUBRIC", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                        ..._rubricItems.map((item) {
                          final isMcq = item["type"] == "MCQ";
                          return TableRow(
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "Q${item['q']}",
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryNavy),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isMcq ? AppColors.brandIndigoLight : AppColors.warningBackdrop,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['type'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isMcq ? AppColors.brandIndigo : AppColors.warningAmber,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(item['topic'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  item['key'],
                                  style: const TextStyle(fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  "+${item['points'].toStringAsFixed(0)} pts",
                                  style: const TextStyle(fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.successGreen),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['coords'], style: const TextStyle(fontFamily: 'Courier', fontSize: 11, color: AppColors.textSecondary)),
                                    const SizedBox(height: 2),
                                    Text(item['steps'], style: const TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                                  ],
                                ),
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
}
