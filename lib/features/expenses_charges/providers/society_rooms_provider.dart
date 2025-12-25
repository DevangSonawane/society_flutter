import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/society_room_model.dart';
import '../data/repositories/society_room_repository.dart';

final societyRoomRepositoryProvider = Provider<SocietyRoomRepository>((ref) {
  return SocietyRoomRepository();
});

final societyRoomsProvider = FutureProvider<List<SocietyRoomModel>>((ref) {
  final repository = ref.watch(societyRoomRepositoryProvider);
  return repository.getRooms();
});

class SocietyRoomsNotifier extends StateNotifier<AsyncValue<List<SocietyRoomModel>>> {
  SocietyRoomsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadRooms();
  }

  final SocietyRoomRepository repository;

  Future<void> loadRooms() async {
    state = const AsyncValue.loading();
    try {
      final rooms = await repository.getRooms();
      state = AsyncValue.data(rooms);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createRoom(SocietyRoomModel room) async {
    try {
      await repository.createRoom(room);
      await loadRooms();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateRoom(SocietyRoomModel room) async {
    try {
      await repository.updateRoom(room);
      await loadRooms();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteRoom(String id) async {
    try {
      await repository.deleteRoom(id);
      await loadRooms();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final societyRoomsNotifierProvider = StateNotifierProvider<SocietyRoomsNotifier, AsyncValue<List<SocietyRoomModel>>>((ref) {
  final repository = ref.watch(societyRoomRepositoryProvider);
  return SocietyRoomsNotifier(repository);
});

