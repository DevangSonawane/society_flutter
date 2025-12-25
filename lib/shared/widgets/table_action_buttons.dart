import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/haptic_helper.dart';

class TableActionButtons extends StatelessWidget {
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showView;
  final bool showEdit;
  final bool showDelete;

  const TableActionButtons({
    super.key,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.showView = true,
    this.showEdit = true,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showView && onView != null)
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 20),
            color: AppColors.infoBlue,
            onPressed: () {
              HapticHelper.light();
              onView!();
            },
            tooltip: 'View',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (showView && onView != null && (showEdit || showDelete))
          const SizedBox(width: 8),
        if (showEdit && onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.primaryPurple,
            onPressed: () {
              HapticHelper.light();
              onEdit!();
            },
            tooltip: 'Edit',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (showEdit && onEdit != null && showDelete)
          const SizedBox(width: 8),
        if (showDelete && onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.errorRed,
            onPressed: () {
              HapticHelper.light();
              onDelete!();
            },
            tooltip: 'Delete',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}

