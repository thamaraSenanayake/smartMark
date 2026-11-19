import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/assessment.dart';

class StatusPill extends StatelessWidget {
  final SyncStatus status;

  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color border;
    IconData icon;
    String label;

    switch (status) {
      case SyncStatus.synced:
        bg = AppColors.successBackdrop;
        text = AppColors.successGreen;
        border = AppColors.successBorder;
        icon = Icons.check_circle_outline;
        label = "Synced";
        break;
      case SyncStatus.pending:
        bg = AppColors.warningBackdrop;
        text = AppColors.warningAmber;
        border = AppColors.warningBorder;
        icon = Icons.access_time;
        label = "Pending";
        break;
      case SyncStatus.retrying:
        bg = AppColors.errorBackdrop;
        text = AppColors.errorRose;
        border = AppColors.errorBorder;
        icon = Icons.sync;
        label = "Retrying";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class GradeBadge extends StatelessWidget {
  final String grade;

  const GradeBadge({super.key, required this.grade});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;

    switch (grade) {
      case 'A':
        bg = AppColors.successBackdrop;
        text = AppColors.successGreen;
        break;
      case 'B':
        bg = AppColors.brandIndigoLight;
        text = AppColors.brandIndigo;
        break;
      case 'C':
        bg = AppColors.warningBackdrop;
        text = AppColors.warningAmber;
        break;
      default:
        bg = AppColors.errorBackdrop;
        text = AppColors.errorRose;
        break;
    }

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: text.withOpacity(0.3)),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}
