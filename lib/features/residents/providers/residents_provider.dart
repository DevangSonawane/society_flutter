import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/resident_model.dart';
import '../data/repositories/resident_repository.dart';

final residentRepositoryProvider = Provider<ResidentRepository>((ref) {
  return ResidentRepository();
});

final residentsProvider = FutureProvider<List<ResidentModel>>((ref) {
  final repository = ref.watch(residentRepositoryProvider);
  return repository.getResidents();
});

final residentByIdProvider = FutureProvider.family<ResidentModel?, String>((ref, id) {
  final repository = ref.watch(residentRepositoryProvider);
  return repository.getResidentById(id);
});

class ResidentsNotifier extends StateNotifier<AsyncValue<List<ResidentModel>>> {
  ResidentsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadResidents();
  }

  final ResidentRepository repository;

  Future<void> loadResidents() async {
    state = const AsyncValue.loading();
    try {
      final residents = await repository.getResidents();
      state = AsyncValue.data(residents);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createResident(ResidentModel resident) async {
    try {
      await repository.createResident(resident);
      await loadResidents();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateResident(ResidentModel resident) async {
    try {
      await repository.updateResident(resident);
      await loadResidents();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteResident(String id) async {
    try {
      await repository.deleteResident(id);
      await loadResidents();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final residentsNotifierProvider = StateNotifierProvider<ResidentsNotifier, AsyncValue<List<ResidentModel>>>((ref) {
  final repository = ref.watch(residentRepositoryProvider);
  return ResidentsNotifier(repository);
});

