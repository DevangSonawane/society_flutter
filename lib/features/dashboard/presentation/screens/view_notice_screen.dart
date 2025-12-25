import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/notice_model.dart';
import 'edit_notice_screen.dart';

class ViewNoticeScreen extends StatelessWidget {
  final NoticeModel notice;

  const ViewNoticeScreen({
    super.key,
    required this.notice,
  });

  Color _getPriorityColor(NoticePriority priority) {
    switch (priority) {
      case NoticePriority.high:
        return AppColors.errorRed;
      case NoticePriority.medium:
        return AppColors.warningYellow;
      case NoticePriority.low:
        return AppColors.successGreen;
    }
  }

  Color _getCategoryColor(NoticeCategory category) {
    switch (category) {
      case NoticeCategory.emergency:
        return AppColors.errorRed;
      case NoticeCategory.maintenance:
        return AppColors.infoBlue;
      case NoticeCategory.event:
        return AppColors.primaryPurple;
      case NoticeCategory.general:
        return AppColors.textSecondary;
    }
  }

  String _getPriorityLabel(NoticePriority priority) {
    switch (priority) {
      case NoticePriority.high:
        return 'High';
      case NoticePriority.medium:
        return 'Medium';
      case NoticePriority.low:
        return 'Low';
    }
  }

  String _getCategoryLabel(NoticeCategory category) {
    switch (category) {
      case NoticeCategory.general:
        return 'General';
      case NoticeCategory.maintenance:
        return 'Maintenance';
      case NoticeCategory.event:
        return 'Event';
      case NoticeCategory.emergency:
        return 'Emergency';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notice Details',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryPurple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNoticeScreen(notice: notice),
                ),
              );
            },
            tooltip: 'Edit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeSlideWidget(
              delay: const Duration(milliseconds: 100),
              child: CustomButton(
                text: 'Back to Notice Board',
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
                type: ButtonType.secondary,
              ),
            ),
            const SizedBox(height: 24),
            
            FadeSlideWidget(
              delay: const Duration(milliseconds: 200),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.campaign,
                            color: AppColors.primaryPurple,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              notice.title,
                              style: AppTextStyles.h2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Priority and Category Badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(notice.priority).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getPriorityColor(notice.priority),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getPriorityLabel(notice.priority),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _getPriorityColor(notice.priority),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(notice.category).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getCategoryColor(notice.category),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getCategoryLabel(notice.category),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _getCategoryColor(notice.category),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Content
                      Text(
                        'Content',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notice.content,
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      
                      // Details
                      Divider(color: AppColors.borderLight),
                      const SizedBox(height: 16),
                      
                      _buildDetailRow(
                        'Date',
                        AppFormatters.date(notice.date),
                        Icons.calendar_today,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Author',
                        notice.author,
                        Icons.person,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Created',
                        AppFormatters.dateTime(notice.createdAt),
                        Icons.access_time,
                      ),
                      if (notice.updatedAt != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          'Last Updated',
                          AppFormatters.dateTime(notice.updatedAt!),
                          Icons.update,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}

