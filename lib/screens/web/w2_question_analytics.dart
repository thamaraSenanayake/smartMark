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
    final hasScans = MockData.studentScans.isNotEmpty;

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
                  backgroundColor: blindSpotCount > 0 ? AppColors.errorBackdrop : AppColors.cardBg,
                  border: Border.all(color: blindSpotCount > 0 ? AppColors.errorBorder : AppColors.borderLight),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: blindSpotCount > 0 ? AppColors.errorRose : AppColors.brandIndigoLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          blindSpotCount > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          color: blindSpotCount > 0 ? Colors.white : AppColors.brandIndigo,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasScans
                                  ? "$blindSpotCount Critical Blind-Spots Detected"
                                  : "Awaiting Assessment Data",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: blindSpotCount > 0 ? AppColors.errorRose : AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasScans
                                  ? (blindSpotCount > 0
                                      ? "Questions fell below the 50% class passing threshold."
                                      : "All evaluated questions exceeded the passing benchmark.")
                                  : "Scan papers with the teacher camera to calculate item difficulty.",
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                  backgroundColor: ambiguousCount > 0 ? AppColors.warningBackdrop : AppColors.cardBg,
                  border: Border.all(color: ambiguousCount > 0 ? AppColors.warningBorder : AppColors.borderLight),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ambiguousCount > 0 ? AppColors.warningAmber : AppColors.brandIndigoLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.psychology_outlined,
                          color: ambiguousCount > 0 ? Colors.white : AppColors.brandIndigo,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasScans
                                  ? "$ambiguousCount Ambiguous Items (Low DI)"
                                  : "Discrimination Index Pending",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: ambiguousCount > 0 ? AppColors.warningAmber : AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasScans
                                  ? (ambiguousCount > 0
                                      ? "Items with DI < 0.20 indicate potential ambiguous wording."
                                      : "High item discrimination across student scoring brackets.")
                                  : "Correlates top vs bottom student quartile outcomes.",
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.bar_chart_outlined, size: 48, color: AppColors.textSecondary),
                          SizedBox(height: 12),
                          Text(
                            "No Question Responses Recorded",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Once papers are scanned on the mobile scanner, per-question correct/incorrect ratios will appear here.",
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...items.map((item) => ItemMatrixBar(item: item)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
