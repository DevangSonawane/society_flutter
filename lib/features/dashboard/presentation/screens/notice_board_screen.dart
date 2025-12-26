import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/statistics_card.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/responsive_statistics_grid.dart';
import '../../../../shared/widgets/animations/shimmer_loading.dart';
import '../../../../shared/widgets/animated_dialog.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../../../shared/widgets/data_table_widget.dart';
import '../../../../shared/widgets/table_action_buttons.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/permissions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../data/models/notice_model.dart';
import '../../providers/notices_provider.dart';
import 'add_notice_screen.dart';
import 'edit_notice_screen.dart';
import 'view_notice_screen.dart';

class NoticeBoardScreen extends ConsumerStatefulWidget {
  const NoticeBoardScreen({super.key});

  @override
  ConsumerState<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends ConsumerState<NoticeBoardScreen> {
  String _searchQuery = '';

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

  Future<void> _deleteNotice(String id, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AnimatedAlertDialog(
        title: 'Delete Notice',
        content: Text('Are you sure you want to delete "$title"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(noticesNotifierProvider.notifier).deleteNotice(id);
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Notice deleted successfully',
            type: SnackbarType.success,
          );
        }
      } catch (e) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: 'Error deleting notice: ${e.toString()}',
            type: SnackbarType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final noticesAsync = ref.watch(noticesNotifierProvider);
    final user = ref.watch(authProvider);
    final userRole = Permissions.getUserRole(user);
    final canAddNotice = Permissions.canAddNotice(userRole);
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.getScreenPadding(context);

    return noticesAsync.when(
      data: (notices) {
        final thisMonth = notices.where((n) {
          final now = DateTime.now();
          return n.createdAt.month == now.month && n.createdAt.year == now.year;
        }).length;
        final highPriority = notices.where((n) => n.priority == NoticePriority.high).length;
        
        // Filter notices based on search query
        final filteredNotices = _searchQuery.isEmpty
            ? notices
            : notices.where((n) {
                final query = _searchQuery.toLowerCase();
                return n.title.toLowerCase().contains(query) ||
                    n.content.toLowerCase().contains(query) ||
                    n.author.toLowerCase().contains(query) ||
                    _getCategoryLabel(n.category).toLowerCase().contains(query);
              }).toList();
        
        return Container(
          color: AppColors.backgroundLight,
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notice Board', style: AppTextStyles.h1),
                          const SizedBox(height: 4),
                          Text(
                            'Manage and publish notices for residents',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (canAddNotice) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: 'Create Notice',
                                icon: Icons.add,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddNoticeScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Notice Board', style: AppTextStyles.h1),
                              const SizedBox(height: 4),
                              Text(
                                'Manage and publish notices for residents',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (canAddNotice)
                            CustomButton(
                              text: 'Create Notice',
                              icon: Icons.add,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddNoticeScreen(),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                const SizedBox(height: 24),
                
                // Statistics Cards
                ResponsiveStatisticsGrid(
                  children: [
                    StatisticsCard(
                      title: 'Total Notices',
                      value: '${notices.length}',
                      subtitle: 'All notices',
                      borderColor: AppColors.primaryPurple,
                      valueColor: AppColors.primaryPurple,
                      icon: Icons.campaign,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'This Month',
                      value: '$thisMonth',
                      subtitle: 'Notices this month',
                      borderColor: AppColors.infoBlue,
                      valueColor: AppColors.infoBlue,
                      icon: Icons.calendar_today,
                      showTrend: true,
                    ),
                    StatisticsCard(
                      title: 'High Priority',
                      value: '$highPriority',
                      subtitle: 'High priority notices',
                      borderColor: AppColors.errorRed,
                      valueColor: AppColors.errorRed,
                      icon: Icons.priority_high,
                      showTrend: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Search
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search notices by title, content, author, or category...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                
                // Notices Table/Cards
                filteredNotices.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.campaign,
                        title: 'No notices found',
                        message: _searchQuery.isEmpty
                            ? 'Create your first notice to get started'
                            : 'Try adjusting your search query',
                      )
                    : isMobile
                        ? Column(
                            children: filteredNotices.map((notice) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notice.title,
                                              style: AppTextStyles.h4,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _getPriorityColor(notice.priority).withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  _getPriorityLabel(notice.priority),
                                                  style: TextStyle(
                                                    color: _getPriorityColor(notice.priority),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        notice.content,
                                        style: AppTextStyles.bodyMedium,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 8),
                                          Text(notice.author, style: AppTextStyles.bodySmall),
                                          const SizedBox(width: 16),
                                          Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                                          const SizedBox(width: 8),
                                          Text(
                                            AppFormatters.date(notice.date),
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility, size: 20),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ViewNoticeScreen(notice: notice),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditNoticeScreen(notice: notice),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20, color: AppColors.errorRed),
                                            onPressed: () => _deleteNotice(notice.id, notice.title),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : DataTableWidget(
                            columns: const [
                              'Title',
                              'Category',
                              'Priority',
                              'Author',
                              'Date',
                              'Created',
                              'Actions',
                            ],
                            rows: filteredNotices.map((notice) {
                              return [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    notice.title,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(notice.category).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getCategoryLabel(notice.category),
                                    style: TextStyle(
                                      color: _getCategoryColor(notice.category),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(notice.priority).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getPriorityLabel(notice.priority),
                                    style: TextStyle(
                                      color: _getPriorityColor(notice.priority),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(notice.author),
                                Text(AppFormatters.date(notice.date)),
                                Text(AppFormatters.dateTime(notice.createdAt)),
                                TableActionButtons(
                                  onView: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ViewNoticeScreen(notice: notice),
                                      ),
                                    );
                                  },
                                  onEdit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditNoticeScreen(notice: notice),
                                      ),
                                    );
                                  },
                                  onDelete: () => _deleteNotice(notice.id, notice.title),
                                ),
                              ];
                            }).toList(),
                          ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        color: AppColors.backgroundLight,
        child: SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoading(width: 200, height: 32),
              const SizedBox(height: 24),
              ResponsiveStatisticsGrid(
                children: List.generate(3, (index) => const ShimmerLoading(width: double.infinity, height: 120)),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => ErrorStateWidget(
        message: error.toString(),
        onRetry: () => ref.refresh(noticesNotifierProvider),
      ),
    );
  }
}
