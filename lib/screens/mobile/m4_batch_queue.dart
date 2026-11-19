import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import '../../data/mock_data.dart';
import '../../models/assessment.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/custom_card.dart';
import 'm3_grading_overlay.dart';

class BatchQueueScreen extends StatefulWidget {
  const BatchQueueScreen({super.key});

  @override
  State<BatchQueueScreen> createState() => _BatchQueueScreenState();
}

class _BatchQueueScreenState extends State<BatchQueueScreen> {
  bool isSyncing = false;
  late List<StudentExamScan> scans;

  @override
  void initState() {
    super.initState();
    scans = List.from(MockData.studentScans);
  }

  void _triggerCloudSync() async {
    setState(() => isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() {
      for (var s in scans) {
        s.syncStatus = SyncStatus.synced;
      }
      isSyncing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("All 7 local exam scans synced to Cloud Firestore."),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncedCount = scans.where((s) => s.syncStatus == SyncStatus.synced).length;
    final pendingCount = scans.where((s) => s.syncStatus != SyncStatus.synced).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Batch Sync Queue"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isSyncing ? null : _triggerCloudSync,
          ),
        ],
      ),
      body: Column(
        children: [
          // Cloud Sync Status Banner
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.cardBg,
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
                          "OFFLINE STORAGE & CLOUD SYNC",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$syncedCount synced • $pendingCount in offline queue",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandIndigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: isSyncing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.cloud_upload_outlined, size: 16),
                      label: Text(isSyncing ? "Syncing..." : "Sync All"),
                      onPressed: isSyncing ? null : _triggerCloudSync,
                    ),
                  ],
                ),
                if (isSyncing) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(
                    backgroundColor: AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandIndigo),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),

          // Papers List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: scans.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final scan = scans[index];
                return CustomCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InstantVerificationScreen(studentScan: scan),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.asset(
                          scan.imagePath,
                          width: 44,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 44,
                            height: 56,
                            color: Colors.grey[200],
                            child: const Icon(Icons.article, size: 20, color: Colors.grey),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              scan.rollNumber,
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StatusPill(status: scan.syncStatus),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GradeBadge(grade: scan.letterGrade),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
