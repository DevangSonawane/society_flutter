import '../models/permission_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class PermissionRepository {
  final String _table = 'permissions';

  Future<List<PermissionModel>> getPermissions() async {
    return SupabaseService.executeQuery<List<PermissionModel>>(
      context: 'getPermissions',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .order('permission_date', ascending: false);
        
        return (response as List)
            .map((json) => PermissionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<PermissionModel?> getPermissionById(String id) async {
    try {
      return SupabaseService.executeQuery<PermissionModel>(
        context: 'getPermissionById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return PermissionModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('Permission not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<PermissionModel> createPermission(PermissionModel permission) async {
    return SupabaseService.executeQuery<PermissionModel>(
      context: 'createPermission',
      query: () async {
        final data = permission.toJson();
        data.remove('id');
        data.remove('created_at');
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        return PermissionModel.fromJson(response);
      },
    );
  }

  Future<PermissionModel> updatePermission(PermissionModel permission) async {
    return SupabaseService.executeQuery<PermissionModel>(
      context: 'updatePermission',
      query: () async {
        final data = permission.toJson();
        data.remove('created_at');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        final response = await SupabaseService.client
            .from(_table)
            .update(data)
            .eq('id', permission.id)
            .select()
            .single();
        
        return PermissionModel.fromJson(response);
      },
    );
  }

  Future<void> deletePermission(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deletePermission',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('id', id);
      },
    );
  }
}

