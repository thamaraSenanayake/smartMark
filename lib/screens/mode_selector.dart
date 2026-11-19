import 'package:flutter/material.dart';
import 'mobile/auth_screen.dart';
import 'mobile/m1_assessment_hub.dart';
import 'web/web_portal_shell.dart';

enum AppViewMode { mobile, web, auto }

class ModeSelectorScreen extends StatefulWidget {
  const ModeSelectorScreen({super.key});

  @override
  State<ModeSelectorScreen> createState() => _ModeSelectorScreenState();
}

class _ModeSelectorScreenState extends State<ModeSelectorScreen> {
  AppViewMode _currentMode = AppViewMode.auto;
  final bool _isTeacherLoggedIn = true; // Default signed-in for seamless preview

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final activeMode = _currentMode == AppViewMode.auto
            ? (isDesktop ? AppViewMode.web : AppViewMode.mobile)
            : _currentMode;

        if (activeMode == AppViewMode.web) {
          return WebPortalShell(
            onSwitchToMobile: () {
              setState(() => _currentMode = AppViewMode.mobile);
            },
          );
        } else {
          if (!_isTeacherLoggedIn) {
            return TeacherAuthScreen(
              onSwitchToWeb: () {
                setState(() => _currentMode = AppViewMode.web);
              },
            );
          }
          return AssessmentHubScreen(
            onSwitchToWeb: () {
              setState(() => _currentMode = AppViewMode.web);
            },
          );
        }
      },
    );
  }
}
