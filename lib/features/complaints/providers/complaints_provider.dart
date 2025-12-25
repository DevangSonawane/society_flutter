import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/complaint_model.dart';
import '../data/repositories/complaint_repository.dart';

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return ComplaintRepository();
});

final complaintsProvider = FutureProvider<List<ComplaintModel>>((ref) {
  final repository = ref.watch(complaintRepositoryProvider);
  return repository.getComplaints();
});

class ComplaintsNotifier extends StateNotifier<AsyncValue<List<ComplaintModel>>> {
  ComplaintsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadComplaints();
  }

  final ComplaintRepository repository;

  Future<void> loadComplaints() async {
    state = const AsyncValue.loading();
    try {
      final complaints = await repository.getComplaints();
      state = AsyncValue.data(complaints);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createComplaint(ComplaintModel complaint) async {
    try {
      await repository.createComplaint(complaint);
      await loadComplaints();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateComplaint(ComplaintModel complaint) async {
    try {
      await repository.updateComplaint(complaint);
      await loadComplaints();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteComplaint(String id) async {
    try {
      await repository.deleteComplaint(id);
      await loadComplaints();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final complaintsNotifierProvider = StateNotifierProvider<ComplaintsNotifier, AsyncValue<List<ComplaintModel>>>((ref) {
  final repository = ref.watch(complaintRepositoryProvider);
  return ComplaintsNotifier(repository);
});

