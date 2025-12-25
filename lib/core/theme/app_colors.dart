import 'package:flutter/material.dart';

class AppColors {
  // Primary Purple Colors
  static const Color primaryPurple = Color(0xFF7B2CBF);
  static const Color primaryPurpleLight = Color(0xFF9D4EDD);
  static const Color primaryPurpleDark = Color(0xFF5A189A);
  static const Color primaryPurpleGradientStart = Color(0xFF9D4EDD);
  static const Color primaryPurpleGradientEnd = Color(0xFF7B2CBF);
  
  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenLight = Color(0xFFD1FAE5);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorRedLight = Color(0xFFFEE2E2);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color warningYellowLight = Color(0xFFFEF3C7);
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color infoBlueLight = Color(0xFFDBEAFE);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundCard = Color(0xFFFFFFFF);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurpleGradientStart, primaryPurpleGradientEnd],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0D5F5), Color(0xFFD4C4E8)],
  );
}

