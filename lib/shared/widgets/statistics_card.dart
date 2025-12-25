import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'animations/fade_slide_widget.dart';
import 'animations/animated_counter.dart';
import 'animations/pulse_widget.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final Color? borderColor;
  final Color? valueColor;
  final IconData? icon;
  final Widget? trailing;
  final bool showTrend;
  final bool isPulse;
  final Duration? animationDelay;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.borderColor,
    this.valueColor,
    this.icon,
    this.trailing,
    this.showTrend = false,
    this.isPulse = false,
    this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideWidget(
      delay: animationDelay ?? Duration.zero,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: borderColor != null
              ? Border(
                  left: BorderSide(color: borderColor!, width: 5),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Icon Row (Title top-left, Icon top-right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (top-left)
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  // Icon (top-right) with colored circular background
                  if (icon != null)
                    isPulse
                        ? PulseWidget(
                            child: _buildIcon(),
                          )
                        : _buildIcon(),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Value (large number in center)
              _buildValue(),
              
              // Trend Indicator (below value, before subtitle)
              if (showTrend) ...[
                const SizedBox(height: 8),
                _buildTrendIndicator(),
              ],
              
              const SizedBox(height: 8),
              
              // Subtitle (bottom)
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final iconColor = borderColor ?? valueColor ?? AppColors.primaryPurple;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildTrendIndicator() {
    return Row(
      children: [
        Icon(
          Icons.trending_up,
          size: 16,
          color: AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        // Wavy line icon (using show_chart or similar)
        Icon(
          Icons.show_chart,
          size: 14,
          color: AppColors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildValue() {
    // Check if value is a number
    final numValue = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    final displayColor = valueColor ?? borderColor ?? AppColors.primaryPurple;
    
    if (numValue != null) {
      // Animated counter for numbers
      return AnimatedCounter(
        value: numValue,
        textStyle: AppTextStyles.numberLarge.copyWith(
          color: displayColor,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
        prefix: value.startsWith('₹') ? '₹' : '',
      );
    } else {
      // Regular text for non-numbers
      return Text(
        value,
        style: AppTextStyles.numberLarge.copyWith(
          color: displayColor,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}

