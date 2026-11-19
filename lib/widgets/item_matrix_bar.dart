import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/assessment.dart';

class ItemMatrixBar extends StatelessWidget {
  final ItemAnalysis item;

  const ItemMatrixBar({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isBlindSpot ? AppColors.errorBackdrop : AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusWeb),
        border: Border.all(
          color: item.isBlindSpot ? AppColors.errorBorder : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.isBlindSpot ? AppColors.errorRose : AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Q${item.questionNumber}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.topic,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    Text(
                      "Mistake: ${item.commonMistake}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (item.isBlindSpot)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.errorRose,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 12, color: Colors.white),
                      SizedBox(width: 3),
                      Text(
                        "Blind-Spot",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 6),
              _buildDiscriminationBadge(item.discriminationIndex),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(
                  flex: item.correctPercentage.toInt(),
                  child: Container(
                    height: 8,
                    color: AppColors.successGreen,
                  ),
                ),
                Expanded(
                  flex: item.incorrectPercentage.toInt(),
                  child: Container(
                    height: 8,
                    color: AppColors.errorRose,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Correct: ${item.correctPercentage.toStringAsFixed(0)}%",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen,
                ),
              ),
              Text(
                "Failed: ${item.incorrectPercentage.toStringAsFixed(0)}%",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorRose,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscriminationBadge(double discIndex) {
    Color bg;
    Color text;
    String label;

    if (discIndex >= 0.4) {
      bg = AppColors.successBackdrop;
      text = AppColors.successGreen;
      label = "DI: ${discIndex.toStringAsFixed(2)} (High)";
    } else if (discIndex >= 0.2) {
      bg = AppColors.brandIndigoLight;
      text = AppColors.brandIndigo;
      label = "DI: ${discIndex.toStringAsFixed(2)}";
    } else {
      bg = AppColors.warningBackdrop;
      text = AppColors.warningAmber;
      label = "DI: ${discIndex.toStringAsFixed(2)} (Ambiguous)";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: text.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
