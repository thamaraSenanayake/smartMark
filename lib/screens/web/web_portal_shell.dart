import 'package:flutter/material.dart';
import '../../constants/theme.dart';
import 'w1_executive_dashboard.dart';
import 'w2_question_analytics.dart';
import 'w3_student_gradebook.dart';
import 'w4_rubric_manager.dart';

class WebPortalShell extends StatefulWidget {
  final VoidCallback? onSwitchToMobile;

  const WebPortalShell({super.key, this.onSwitchToMobile});

  @override
  State<WebPortalShell> createState() => _WebPortalShellState();
}

class _WebPortalShellState extends State<WebPortalShell> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralCanvas,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.brandIndigo,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              "SmartMark Portal",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.primaryNavy,
              ),
            ),
          ],
        ),
        actions: [
          // Switch to Mobile Scanner mode
          if (widget.onSwitchToMobile != null)
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.brandIndigo,
                backgroundColor: AppColors.brandIndigoLight,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.phone_android, size: 15),
              label: const Text(
                "Mobile Scanner",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              onPressed: widget.onSwitchToMobile,
            ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primaryNavy,
            child: Text(
              "P",
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.cardBg,
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 0.5),
                bottom: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildNavTab("Executive Overview", 0, Icons.dashboard_outlined),
                  const SizedBox(width: 8),
                  _buildNavTab("Question Analytics", 1, Icons.insights_outlined),
                  const SizedBox(width: 8),
                  _buildNavTab("Student Gradebook", 2, Icons.people_outline),
                  const SizedBox(width: 8),
                  _buildNavTab("Rubric & Scheme Manager", 3, Icons.tune_outlined),
                ],
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _activeTab,
        children: [
          ExecutiveDashboardScreen(
            onNavigateToQuestions: () => setState(() => _activeTab = 1),
            onNavigateToGradebook: () => setState(() => _activeTab = 2),
          ),
          const QuestionAnalyticsScreen(),
          const StudentGradebookScreen(),
          const RubricManagerScreen(),
        ],
      ),
    );
  }

  Widget _buildNavTab(String label, int index, IconData icon) {
    final isActive = _activeTab == index;

    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.brandIndigo : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? AppColors.brandIndigo : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.brandIndigo : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
