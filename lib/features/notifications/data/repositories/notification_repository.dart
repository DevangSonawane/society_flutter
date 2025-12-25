import '../models/notification_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class NotificationRepository {
  final String _table = 'notifications';

  Future<List<NotificationModel>> getNotifications({
    bool? unreadOnly,
    int? limit,
  }) async {
    return SupabaseService.executeQuery<List<NotificationModel>>(
      context: 'getNotifications',
      query: () async {
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
      },
    );
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
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('Notification not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    return SupabaseService.executeQuery<int>(
      context: 'getUnreadCount',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select('id')
            .eq('is_read', false);
        
        return (response as List).length;
      },
    );
  }

  Future<NotificationModel> createNotification(NotificationModel notification) async {
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
  }

  Future<void> markAsRead(String id) async {
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
  }

  Future<void> markAllAsRead() async {
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
  }

  Future<void> deleteNotification(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deleteNotification',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('id', id);
      },
    );
  }
}

