import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'custom_button.dart';

class RetryWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData? icon;

  const RetryWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Retry',
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

