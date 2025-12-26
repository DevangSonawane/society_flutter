import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/maintenance_payment_model.dart';
import '../data/repositories/maintenance_payment_repository.dart';

final maintenancePaymentRepositoryProvider = Provider<MaintenancePaymentRepository>((ref) {
  return MaintenancePaymentRepository();
});

final maintenancePaymentsProvider = FutureProvider<List<MaintenancePaymentModel>>((ref) {
  final repository = ref.watch(maintenancePaymentRepositoryProvider);
  return repository.getPayments();
});

class MaintenancePaymentsNotifier extends StateNotifier<AsyncValue<List<MaintenancePaymentModel>>> {
  MaintenancePaymentsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadPayments();
  }

  final MaintenancePaymentRepository repository;

  Future<void> loadPayments() async {
    state = const AsyncValue.loading();
    try {
      final payments = await repository.getPayments();
      state = AsyncValue.data(payments);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createPayment(MaintenancePaymentModel payment) async {
    try {
      await repository.createPayment(payment);
      await loadPayments();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updatePayment(MaintenancePaymentModel payment) async {
    try {
      await repository.updatePayment(payment);
      await loadPayments();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      await repository.deletePayment(id);
      await loadPayments();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> generatePaymentsForMonth({
    required int month,
    required int year,
    required double amount,
    required List<Map<String, dynamic>> residents,
  }) async {
    try {
      await repository.generatePaymentsForMonth(
        month: month,
        year: year,
        amount: amount,
        residents: residents,
      );
      await loadPayments();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final maintenancePaymentsNotifierProvider = StateNotifierProvider<MaintenancePaymentsNotifier, AsyncValue<List<MaintenancePaymentModel>>>((ref) {
  final repository = ref.watch(maintenancePaymentRepositoryProvider);
  return MaintenancePaymentsNotifier(repository);
});

/// Provider for resident's own maintenance payments (filtered by flat number)
final residentMaintenancePaymentsProvider = FutureProvider.family<List<MaintenancePaymentModel>, String>((ref, flatNumber) {
  final repository = ref.watch(maintenancePaymentRepositoryProvider);
  return repository.getPaymentsByFlatNumber(flatNumber);
});

