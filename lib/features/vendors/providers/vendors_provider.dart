import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/vendor_model.dart';
import '../data/repositories/vendor_repository.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepository();
});

final vendorsProvider = FutureProvider<List<VendorModel>>((ref) {
  final repository = ref.watch(vendorRepositoryProvider);
  return repository.getVendors();
});

class VendorsNotifier extends StateNotifier<AsyncValue<List<VendorModel>>> {
  VendorsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadVendors();
  }

  final VendorRepository repository;

  Future<void> loadVendors() async {
    state = const AsyncValue.loading();
    try {
      final vendors = await repository.getVendors();
      state = AsyncValue.data(vendors);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createVendor(VendorModel vendor) async {
    try {
      await repository.createVendor(vendor);
      await loadVendors();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateVendor(VendorModel vendor) async {
    try {
      await repository.updateVendor(vendor);
      await loadVendors();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteVendor(String id) async {
    try {
      await repository.deleteVendor(id);
      await loadVendors();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final vendorsNotifierProvider = StateNotifierProvider<VendorsNotifier, AsyncValue<List<VendorModel>>>((ref) {
  final repository = ref.watch(vendorRepositoryProvider);
  return VendorsNotifier(repository);
});

