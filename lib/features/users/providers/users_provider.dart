import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final usersProvider = FutureProvider<List<UserModel>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsers();
});

class UsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  UsersNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  final UserRepository repository;

  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    try {
      final users = await repository.getUsers();
      state = AsyncValue.data(users);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await repository.createUser(user);
      await loadUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await repository.updateUser(user);
      await loadUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await repository.deleteUser(id);
      await loadUsers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final usersNotifierProvider = StateNotifierProvider<UsersNotifier, AsyncValue<List<UserModel>>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UsersNotifier(repository);
});

