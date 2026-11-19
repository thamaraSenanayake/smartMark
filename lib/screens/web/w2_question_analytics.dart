import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../data/mock_data.dart';
import '../../models/assessment.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/item_matrix_bar.dart';

class QuestionAnalyticsScreen extends StatefulWidget {
  const QuestionAnalyticsScreen({super.key});

  @override
  State<QuestionAnalyticsScreen> createState() =>
      _QuestionAnalyticsScreenState();
}

class _QuestionAnalyticsScreenState extends State<QuestionAnalyticsScreen> {
  String filterMode = "All"; // "All", "Blind-Spots Only", "Ambiguous Only"

  @override
  Widget build(BuildContext context) {
    List<ItemAnalysis> items = MockData.itemAnalytics;
    if (filterMode == "Blind-Spots Only") {
      items = items.where((i) => i.isBlindSpot).toList();
    } else if (filterMode == "Ambiguous Only") {
      items = items.where((i) => i.discriminationIndex < 0.2).toList();
    }

    final blindSpotCount = MockData.itemAnalytics.where((i) => i.isBlindSpot).length;
    final ambiguousCount = MockData.itemAnalytics.where((i) => i.discriminationIndex < 0.2).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Item Difficulty & Question Analytics",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Psychometric Item-Response Matrix & Curriculum Blind-Spot Detection",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Filter Chips
              SegmentedButton<String>(
                segments: [
                  const ButtonSegment(value: "All", label: Text("All Questions")),
                  ButtonSegment(
                    value: "Blind-Spots Only",
                    label: Text("Blind-Spots ($blindSpotCount)"),
                  ),
                  ButtonSegment(
                    value: "Ambiguous Only",
                    label: Text("Ambiguous ($ambiguousCount)"),
                  ),
                ],
                selected: {filterMode},
                onSelectionChanged: (newSet) {
                  setState(() => filterMode = newSet.first);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Diagnostic Summary Cards
          Row(
            children: [
              Expanded(
                child: CustomCard(
                  borderRadius: AppTheme.radiusWeb,
                  backgroundColor: AppColors.errorBackdrop,
                  border: Border.all(color: AppColors.errorBorder),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.errorRose,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "2 Critical Blind-Spots Detected",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.errorRose,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Q7 (Thermodynamics) & Q11 (Kirchhoff's Law) fell below 50% class passing benchmark.",
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomCard(
                  borderRadius: AppTheme.radiusWeb,
                  backgroundColor: AppColors.warningBackdrop,
                  border: Border.all(color: AppColors.warningBorder),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warningAmber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "1 Ambiguous Item (Low DI)",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.warningAmber,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Q11 has DI = 0.08. Top-quartile students failed at equal rates due to confusing node arrows.",
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Item-Response Matrix
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
                      "Per-Question Item Response Matrix",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    Row(
                      children: [
                        Container(width: 10, height: 10, color: AppColors.successGreen),
                        const SizedBox(width: 4),
                        const Text("Correct (%)", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(width: 12),
                        Container(width: 10, height: 10, color: AppColors.errorRose),
                        const SizedBox(width: 4),
                        const Text("Incorrect (%)", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...items.map((item) => ItemMatrixBar(item: item)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
