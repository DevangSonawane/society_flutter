import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/animations/fade_in_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/animations/shimmer_loading.dart';
import '../../data/models/notification_model.dart';
import '../../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.complaint:
        return Icons.report_problem;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.permission:
        return Icons.check_circle;
      case NotificationType.maintenance:
        return Icons.build;
      case NotificationType.notice:
        return Icons.campaign;
      case NotificationType.general:
        return Icons.info;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.complaint:
        return AppColors.errorRed;
      case NotificationType.payment:
        return AppColors.successGreen;
      case NotificationType.permission:
        return AppColors.infoBlue;
      case NotificationType.maintenance:
        return AppColors.warningYellow;
      case NotificationType.notice:
        return AppColors.primaryPurple;
      case NotificationType.general:
        return AppColors.textSecondary;
    }
  }

  Color _getPriorityColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return AppColors.errorRed;
      case NotificationPriority.medium:
        return AppColors.warningYellow;
      case NotificationPriority.low:
        return AppColors.successGreen;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications', style: AppTextStyles.h2),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              return TextButton(
                onPressed: () async {
                  await ref.read(notificationsNotifierProvider.notifier).markAllAsRead();
                },
                child: Text(
                  'Mark all read',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryPurple,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.notifications_none,
              title: 'No notifications',
              message: 'You\'re all caught up!',
            );
          }

          final unreadNotifications = notifications.where((n) => !n.isRead).toList();
          final readNotifications = notifications.where((n) => n.isRead).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsNotifierProvider);
            },
            child: CustomScrollView(
              slivers: [
                if (unreadNotifications.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Unread',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notification = unreadNotifications[index];
                        return _buildNotificationTile(context, ref, notification, true);
                      },
                      childCount: unreadNotifications.length,
                    ),
                  ),
                ],
                if (readNotifications.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Read',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notification = readNotifications[index];
                        return _buildNotificationTile(context, ref, notification, false);
                      },
                      childCount: readNotifications.length,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(width: 200, height: 16),
                    const SizedBox(height: 8),
                    ShimmerLoading(width: double.infinity, height: 14),
                  ],
                ),
              ),
            );
          },
        ),
        error: (error, stack) {
          // Check if it's a table not found error
          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains('does not exist') || 
              errorStr.contains('not found') ||
              errorStr.contains('schema cache') ||
              errorStr.contains('could not find the table') ||
              errorStr.contains('public.notifications') ||
              errorStr.contains('public.notification')) {
            return EmptyStateWidget(
              icon: Icons.notifications_off,
              title: 'Notifications Not Available',
              message: 'The notifications feature requires a database table to be set up. Please contact your administrator.',
            );
          }
          return ErrorStateWidget(
            message: error.toString(),
            onRetry: () => ref.refresh(notificationsNotifierProvider),
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
    bool isUnread,
  ) {
    final typeColor = _getTypeColor(notification.type);
    final typeIcon = _getTypeIcon(notification.type);

    return FadeInWidget(
      delay: Duration(milliseconds: 50),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isUnread
                ? typeColor.withOpacity(0.3)
                : AppColors.borderLight,
            width: isUnread ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () async {
            if (isUnread) {
              await ref.read(notificationsNotifierProvider.notifier).markAsRead(notification.id);
            }
            // TODO: Navigate to related item if relatedId is present
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                                color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: typeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppFormatters.relativeTime(notification.createdAt),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          if (notification.priority == NotificationPriority.high) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getPriorityColor(notification.priority).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'High',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: _getPriorityColor(notification.priority),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: AppColors.textTertiary, size: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    if (isUnread)
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.check, size: 18),
                            const SizedBox(width: 8),
                            Text('Mark as read'),
                          ],
                        ),
                        onTap: () async {
                          await ref.read(notificationsNotifierProvider.notifier).markAsRead(notification.id);
                        },
                      ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, size: 18, color: AppColors.errorRed),
                          const SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.errorRed)),
                        ],
                      ),
                      onTap: () async {
                        await ref.read(notificationsNotifierProvider.notifier).deleteNotification(notification.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

