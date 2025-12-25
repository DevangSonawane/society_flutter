import 'package:flutter/material.dart';

class AnimationConstants {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration verySlow = Duration(milliseconds: 1200);
  
  // Curve constants
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve enterCurve = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;
  static const Curve bounceCurve = Curves.elasticOut;
  
  // Animation values
  static const double scaleDown = 0.95;
  static const double scaleUp = 1.05;
  static const double slideDistance = 50.0;
  
  // Stagger delays
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration cardStaggerDelay = Duration(milliseconds: 100);
}

