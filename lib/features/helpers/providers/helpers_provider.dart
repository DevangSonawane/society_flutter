import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/helper_model.dart';
import '../data/repositories/helper_repository.dart';

final helperRepositoryProvider = Provider<HelperRepository>((ref) {
  return HelperRepository();
});

final helpersProvider = FutureProvider<List<HelperModel>>((ref) {
  final repository = ref.watch(helperRepositoryProvider);
  return repository.getHelpers();
});

class HelpersNotifier extends StateNotifier<AsyncValue<List<HelperModel>>> {
  HelpersNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadHelpers();
  }

  final HelperRepository repository;

  Future<void> loadHelpers() async {
    state = const AsyncValue.loading();
    try {
      final helpers = await repository.getHelpers();
      state = AsyncValue.data(helpers);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createHelper(HelperModel helper) async {
    try {
      await repository.createHelper(helper);
      await loadHelpers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateHelper(HelperModel helper) async {
    try {
      await repository.updateHelper(helper);
      await loadHelpers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteHelper(String id) async {
    try {
      await repository.deleteHelper(id);
      await loadHelpers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final helpersNotifierProvider = StateNotifierProvider<HelpersNotifier, AsyncValue<List<HelperModel>>>((ref) {
  final repository = ref.watch(helperRepositoryProvider);
  return HelpersNotifier(repository);
});

