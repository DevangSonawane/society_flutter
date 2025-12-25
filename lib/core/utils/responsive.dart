import 'package:flutter/material.dart';

class Responsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static double getDrawerWidth(BuildContext context) {
    if (isMobile(context)) {
      return MediaQuery.of(context).size.width * 0.85;
    }
    return 280.0;
  }

  static int getStatCardsCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    }
    return const EdgeInsets.all(24.0);
  }

  static double getCardSpacing(BuildContext context) {
    if (isMobile(context)) return 12.0;
    return 16.0;
  }
}

