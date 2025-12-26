import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/billing_history_model.dart';
import '../data/repositories/billing_history_repository.dart';

final billingHistoryRepositoryProvider = Provider<BillingHistoryRepository>((ref) {
  return BillingHistoryRepository();
});

final billingHistoryProvider = FutureProvider<List<BillingHistoryModel>>((ref) {
  final repository = ref.watch(billingHistoryRepositoryProvider);
  return repository.getBillingHistory();
});

class BillingHistoryNotifier extends StateNotifier<AsyncValue<List<BillingHistoryModel>>> {
  BillingHistoryNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadBillingHistory();
  }

  final BillingHistoryRepository repository;

  Future<void> loadBillingHistory() async {
    state = const AsyncValue.loading();
    try {
      final history = await repository.getBillingHistory();
      state = AsyncValue.data(history);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> recordPayment(BillingHistoryModel payment) async {
    try {
      await repository.recordPayment(payment);
      await loadBillingHistory();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final billingHistoryNotifierProvider = StateNotifierProvider<BillingHistoryNotifier, AsyncValue<List<BillingHistoryModel>>>((ref) {
  final repository = ref.watch(billingHistoryRepositoryProvider);
  return BillingHistoryNotifier(repository);
});

