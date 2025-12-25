import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionsProvider = FutureProvider<List<TransactionModel>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getTransactions();
});

class FinanceNotifier extends StateNotifier<AsyncValue<List<TransactionModel>>> {
  FinanceNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  final TransactionRepository repository;

  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await repository.getTransactions();
      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await repository.createTransaction(transaction);
      await loadTransactions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await repository.updateTransaction(transaction);
      await loadTransactions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await repository.deleteTransaction(id);
      await loadTransactions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final financeNotifierProvider = StateNotifierProvider<FinanceNotifier, AsyncValue<List<TransactionModel>>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return FinanceNotifier(repository);
});

