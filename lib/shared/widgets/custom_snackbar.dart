import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum SnackbarType { success, error, warning, info }

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIcon(type),
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getColor(type),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning;
      case SnackbarType.info:
        return Icons.info;
    }
  }

  static Color _getColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return AppColors.successGreen;
      case SnackbarType.error:
        return AppColors.errorRed;
      case SnackbarType.warning:
        return AppColors.warningYellow;
      case SnackbarType.info:
        return AppColors.infoBlue;
    }
  }
}

