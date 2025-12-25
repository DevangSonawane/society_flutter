import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticHelper {
  static Future<void> light() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await HapticFeedback.lightImpact();
    }
  }

  static Future<void> medium() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> heavy() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await HapticFeedback.heavyImpact();
    }
  }

  static Future<void> selection() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await HapticFeedback.selectionClick();
    }
  }

  static Future<void> success() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await Vibration.vibrate(pattern: [0, 100, 50, 100]);
    }
  }

  static Future<void> error() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await Vibration.vibrate(pattern: [0, 50, 50, 50, 50, 50]);
    }
  }
}

