import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/permission_model.dart';
import '../data/repositories/permission_repository.dart';

final permissionRepositoryProvider = Provider<PermissionRepository>((ref) {
  return PermissionRepository();
});

final permissionsProvider = FutureProvider<List<PermissionModel>>((ref) {
  final repository = ref.watch(permissionRepositoryProvider);
  return repository.getPermissions();
});

class PermissionsNotifier extends StateNotifier<AsyncValue<List<PermissionModel>>> {
  PermissionsNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadPermissions();
  }

  final PermissionRepository repository;

  Future<void> loadPermissions() async {
    state = const AsyncValue.loading();
    try {
      final permissions = await repository.getPermissions();
      state = AsyncValue.data(permissions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createPermission(PermissionModel permission) async {
    try {
      await repository.createPermission(permission);
      await loadPermissions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updatePermission(PermissionModel permission) async {
    try {
      await repository.updatePermission(permission);
      await loadPermissions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deletePermission(String id) async {
    try {
      await repository.deletePermission(id);
      await loadPermissions();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final permissionsNotifierProvider = StateNotifierProvider<PermissionsNotifier, AsyncValue<List<PermissionModel>>>((ref) {
  final repository = ref.watch(permissionRepositoryProvider);
  return PermissionsNotifier(repository);
});

