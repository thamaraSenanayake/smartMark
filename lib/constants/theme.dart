import 'package:flutter/material.dart';

class AppColors {
  // Primary & Brand
  static const Color primaryNavy = Color(0xFF0F172A); // Deep Academic Navy
  static const Color brandIndigo = Color(0xFF4F46E5); // Vivid Indigo / Electric Royal
  static const Color brandIndigoLight = Color(0xFFEEF2FF);

  // Success / Correct Answer
  static const Color successGreen = Color(0xFF10B981); // Emerald Green
  static const Color successBackdrop = Color(0xFFECFDF5); // Soft tinted backdrop
  static const Color successBorder = Color(0xFFA7F3D0);

  // Error / Wrong Answer
  static const Color errorRose = Color(0xFFF43F5E); // Crimson Rose
  static const Color errorBackdrop = Color(0xFFFFF1F2); // Soft tinted backdrop
  static const Color errorBorder = Color(0xFFFECDD3);

  // Warning / Needs Audit
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningBackdrop = Color(0xFFFEF3C7);
  static const Color warningBorder = Color(0xFFFDE68A);

  // Neutrals
  static const Color neutralCanvas = Color(0xFFF8FAFC); // Off-White
  static const Color cardBg = Color(0xFFFFFFFF); // Pure White
  static const Color borderLight = Color(0xFFE2E8F0); // 1px border
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
}

class AppTheme {
  static const double radiusMobile = 12.0;
  static const double radiusWeb = 8.0;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.neutralCanvas,
    colorScheme: const ColorScheme.light(
      primary: AppColors.brandIndigo,
      onPrimary: Colors.white,
      secondary: AppColors.primaryNavy,
      surface: AppColors.cardBg,
      error: AppColors.errorRose,
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cardBg,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      iconTheme: IconThemeData(color: AppColors.primaryNavy),
      titleTextStyle: TextStyle(
        color: AppColors.primaryNavy,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      shape: Border(
        bottom: BorderSide(color: AppColors.borderLight, width: 1),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMobile),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
    ),
  );

  static const TextStyle monoScoreStyle = TextStyle(
    fontFamily: 'Courier',
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
}
