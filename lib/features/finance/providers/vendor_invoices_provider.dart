import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/vendor_invoice_model.dart';
import '../data/repositories/vendor_invoice_repository.dart';

final vendorInvoiceRepositoryProvider = Provider<VendorInvoiceRepository>((ref) {
  return VendorInvoiceRepository();
});

final vendorInvoicesProvider = FutureProvider<List<VendorInvoiceModel>>((ref) {
  final repository = ref.watch(vendorInvoiceRepositoryProvider);
  return repository.getVendorInvoices();
});

class VendorInvoicesNotifier extends StateNotifier<AsyncValue<List<VendorInvoiceModel>>> {
  VendorInvoicesNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadInvoices();
  }

  final VendorInvoiceRepository repository;

  Future<void> loadInvoices() async {
    state = const AsyncValue.loading();
    try {
      final invoices = await repository.getVendorInvoices();
      state = AsyncValue.data(invoices);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createInvoice(VendorInvoiceModel invoice) async {
    try {
      await repository.createInvoice(invoice);
      await loadInvoices();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateInvoice(VendorInvoiceModel invoice) async {
    try {
      await repository.updateInvoice(invoice);
      await loadInvoices();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      await repository.deleteInvoice(id);
      await loadInvoices();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final vendorInvoicesNotifierProvider = StateNotifierProvider<VendorInvoicesNotifier, AsyncValue<List<VendorInvoiceModel>>>((ref) {
  final repository = ref.watch(vendorInvoiceRepositoryProvider);
  return VendorInvoicesNotifier(repository);
});

