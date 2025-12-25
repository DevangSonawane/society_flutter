import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/deposit_model.dart';
import '../data/repositories/deposit_repository.dart';

final depositRepositoryProvider = Provider<DepositRepository>((ref) {
  return DepositRepository();
});

final depositsProvider = FutureProvider<List<DepositModel>>((ref) {
  final repository = ref.watch(depositRepositoryProvider);
  return repository.getDeposits();
});

class DepositsNotifier extends StateNotifier<AsyncValue<List<DepositModel>>> {
  DepositsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadDeposits();
  }

  final DepositRepository repository;

  Future<void> loadDeposits() async {
    state = const AsyncValue.loading();
    try {
      final deposits = await repository.getDeposits();
      state = AsyncValue.data(deposits);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createDeposit(DepositModel deposit) async {
    try {
      await repository.createDeposit(deposit);
      await loadDeposits();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateDeposit(DepositModel deposit) async {
    try {
      await repository.updateDeposit(deposit);
      await loadDeposits();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteDeposit(String id) async {
    try {
      await repository.deleteDeposit(id);
      await loadDeposits();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final depositsNotifierProvider = StateNotifierProvider<DepositsNotifier, AsyncValue<List<DepositModel>>>((ref) {
  final repository = ref.watch(depositRepositoryProvider);
  return DepositsNotifier(repository);
});

