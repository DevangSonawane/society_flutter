import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/notice_model.dart';
import '../data/repositories/notice_repository.dart';

final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  return NoticeRepository();
});

final noticesProvider = FutureProvider<List<NoticeModel>>((ref) {
  final repository = ref.watch(noticeRepositoryProvider);
  return repository.getNotices();
});

final noticeByIdProvider = FutureProvider.family<NoticeModel?, String>((ref, id) {
  final repository = ref.watch(noticeRepositoryProvider);
  return repository.getNoticeById(id);
});

class NoticesNotifier extends StateNotifier<AsyncValue<List<NoticeModel>>> {
  NoticesNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadNotices();
  }

  final NoticeRepository repository;

  Future<void> loadNotices() async {
    state = const AsyncValue.loading();
    try {
      final notices = await repository.getNotices();
      state = AsyncValue.data(notices);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createNotice(NoticeModel notice) async {
    try {
      await repository.createNotice(notice);
      await loadNotices();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateNotice(NoticeModel notice) async {
    try {
      await repository.updateNotice(notice);
      await loadNotices();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteNotice(String id) async {
    try {
      await repository.deleteNotice(id);
      await loadNotices();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final noticesNotifierProvider = StateNotifierProvider<NoticesNotifier, AsyncValue<List<NoticeModel>>>((ref) {
  final repository = ref.watch(noticeRepositoryProvider);
  return NoticesNotifier(repository);
});

