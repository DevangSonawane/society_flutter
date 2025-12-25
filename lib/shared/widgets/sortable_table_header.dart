import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/haptic_helper.dart';

enum SortDirection { none, ascending, descending }

class SortableTableHeader extends StatelessWidget {
  final String label;
  final SortDirection sortDirection;
  final VoidCallback? onSort;
  final bool isSortable;

  const SortableTableHeader({
    super.key,
    required this.label,
    this.sortDirection = SortDirection.none,
    this.onSort,
    this.isSortable = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSortable || onSort == null) {
      return Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        HapticHelper.selection();
        onSort!();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          _buildSortIcon(),
        ],
      ),
    );
  }

  Widget _buildSortIcon() {
    IconData iconData;
    Color iconColor;

    switch (sortDirection) {
      case SortDirection.ascending:
        iconData = Icons.arrow_upward;
        iconColor = AppColors.primaryPurple;
        break;
      case SortDirection.descending:
        iconData = Icons.arrow_downward;
        iconColor = AppColors.primaryPurple;
        break;
      case SortDirection.none:
        iconData = Icons.unfold_more;
        iconColor = AppColors.textTertiary;
        break;
    }

    return Icon(
      iconData,
      size: 16,
      color: iconColor,
    );
  }
}

