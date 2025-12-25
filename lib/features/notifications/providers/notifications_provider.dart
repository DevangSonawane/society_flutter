import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications();
});

final unreadNotificationsCountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount();
});

class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  NotificationsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  final NotificationRepository repository;

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await repository.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await repository.markAsRead(id);
      await loadNotifications();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await repository.markAllAsRead();
      await loadNotifications();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await repository.deleteNotification(id);
      await loadNotifications();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final notificationsNotifierProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationsNotifier(repository);
});

