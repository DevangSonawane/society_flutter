import '../models/notification_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class NotificationRepository {
  final String _table = 'notifications';

  Future<List<NotificationModel>> getNotifications({
    bool? unreadOnly,
    int? limit,
  }) async {
    try {
      // Try to query directly first to catch table not found errors
      var query = SupabaseService.client
          .from(_table)
          .select();

      if (unreadOnly == true) {
        query = query.eq('is_read', false);
      }

      final response = await query.order('created_at', ascending: false).limit(limit ?? 1000);
      
      return (response as List)
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Handle case where notifications table doesn't exist
      // Check for various error message formats
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('does not exist') || 
          errorStr.contains('not found') ||
          errorStr.contains('schema cache') ||
          errorStr.contains('could not find the table') ||
          errorStr.contains('public.notifications') ||
          errorStr.contains('public.notification') ||
          (e is Exception && errorStr.contains('database error'))) {
        LoggerService.warning('Notifications table not found. Returning empty list. Error: $e');
        return <NotificationModel>[];
      }
      // Re-throw if it's not a table not found error
      throw Exception('Error loading notifications: ${SupabaseService.handleError(e, 'getNotifications')}');
    }
  }

  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      return SupabaseService.executeQuery<NotificationModel>(
        context: 'getNotificationById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return NotificationModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('PGRST116') || 
          e.toString().contains('not found') ||
          e.toString().contains('does not exist') ||
          e.toString().contains('schema cache')) {
        LoggerService.warning('Notification not found or table does not exist: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      // Try to query directly first to catch table not found errors
      final response = await SupabaseService.client
          .from(_table)
          .select('id')
          .eq('is_read', false);
      
      return (response as List).length;
    } catch (e) {
      // Handle case where notifications table doesn't exist
      // Check for various error message formats
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('does not exist') || 
          errorStr.contains('not found') ||
          errorStr.contains('schema cache') ||
          errorStr.contains('could not find the table') ||
          errorStr.contains('public.notifications') ||
          errorStr.contains('public.notification') ||
          (e is Exception && errorStr.contains('database error'))) {
        LoggerService.warning('Notifications table not found. Returning 0 unread count. Error: $e');
        return 0;
      }
      // Re-throw if it's not a table not found error
      throw Exception('Error getting unread count: ${SupabaseService.handleError(e, 'getUnreadCount')}');
    }
  }

  Future<NotificationModel> createNotification(NotificationModel notification) async {
    try {
      return SupabaseService.executeQuery<NotificationModel>(
        context: 'createNotification',
        query: () async {
          final user = SupabaseService.client.auth.currentUser;
          if (user == null) {
            throw Exception('User must be authenticated to create notifications');
          }

          final data = notification.toJson();
          data.remove('id');
          data.remove('created_at');
          data['user_id'] = user.id;
          
          final response = await SupabaseService.client
              .from(_table)
              .insert(data)
              .select()
              .single();
          
          return NotificationModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('does not exist') || 
          e.toString().contains('not found') ||
          e.toString().contains('schema cache')) {
        LoggerService.warning('Notifications table does not exist. Cannot create notification.');
        throw Exception('Notifications feature is not available. Please contact administrator to set up the notifications table.');
      }
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await SupabaseService.executeQuery<void>(
        context: 'markAsRead',
        query: () async {
          await SupabaseService.client
              .from(_table)
              .update({
                'is_read': true,
                'read_at': DateTime.now().toIso8601String(),
              })
              .eq('id', id);
        },
      );
    } catch (e) {
      if (e.toString().contains('does not exist') || 
          e.toString().contains('not found') ||
          e.toString().contains('schema cache')) {
        LoggerService.warning('Notifications table does not exist. Cannot mark as read.');
        return; // Silently fail if table doesn't exist
      }
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await SupabaseService.executeQuery<void>(
        context: 'markAllAsRead',
        query: () async {
          final user = SupabaseService.client.auth.currentUser;
          if (user == null) {
            throw Exception('User must be authenticated to mark notifications as read');
          }

          await SupabaseService.client
              .from(_table)
              .update({
                'is_read': true,
                'read_at': DateTime.now().toIso8601String(),
              })
              .eq('user_id', user.id)
              .eq('is_read', false);
        },
      );
    } catch (e) {
      if (e.toString().contains('does not exist') || 
          e.toString().contains('not found') ||
          e.toString().contains('schema cache')) {
        LoggerService.warning('Notifications table does not exist. Cannot mark all as read.');
        return; // Silently fail if table doesn't exist
      }
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await SupabaseService.executeQuery<void>(
        context: 'deleteNotification',
        query: () async {
          await SupabaseService.client
              .from(_table)
              .delete()
              .eq('id', id);
        },
      );
    } catch (e) {
      if (e.toString().contains('does not exist') || 
          e.toString().contains('not found') ||
          e.toString().contains('schema cache')) {
        LoggerService.warning('Notifications table does not exist. Cannot delete notification.');
        return; // Silently fail if table doesn't exist
      }
      rethrow;
    }
  }
}

