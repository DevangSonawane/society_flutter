import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Headings
  static TextStyle h1 = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF7B2CBF),
    height: 1.2,
  );
  
  static TextStyle h2 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF111827),
    height: 1.3,
  );
  
  static TextStyle h3 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF111827),
    height: 1.4,
  );
  
  static TextStyle h4 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF111827),
    height: 1.4,
  );
  
  // Body Text
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: const Color(0xFF111827),
    height: 1.5,
  );
  
  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: const Color(0xFF111827),
    height: 1.5,
  );
  
  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: const Color(0xFF6B7280),
    height: 1.5,
  );
  
  // Large Numbers (for statistics)
  static TextStyle numberLarge = GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static TextStyle numberMedium = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  // Labels
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF111827),
  );
  
  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF6B7280),
  );
  
  // Button Text
  static TextStyle buttonLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  static TextStyle buttonMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  // Link Text
  static TextStyle link = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF7B2CBF),
    decoration: TextDecoration.underline,
  );
}

