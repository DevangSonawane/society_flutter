import '../../../auth/data/models/user_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class UserRepository {
  final String _table = 'users';

  Future<List<UserModel>> getUsers() async {
    return SupabaseService.executeQuery<List<UserModel>>(
      context: 'getUsers',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .order('created_at', ascending: false);
        
        return (response as List)
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      return SupabaseService.executeQuery<UserModel>(
        context: 'getUserById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('user_id', id)
              .single();
          
          return UserModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('User not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<UserModel> createUser(UserModel user) async {
    return SupabaseService.executeQuery<UserModel>(
      context: 'createUser',
      query: () async {
        final data = user.toJson();
        data.remove('created_at');
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        return UserModel.fromJson(response);
      },
    );
  }

  Future<UserModel> updateUser(UserModel user) async {
    return SupabaseService.executeQuery<UserModel>(
      context: 'updateUser',
      query: () async {
        final data = user.toJson();
        data.remove('created_at');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        final response = await SupabaseService.client
            .from(_table)
            .update(data)
            .eq('user_id', user.userId)
            .select()
            .single();
        
        return UserModel.fromJson(response);
      },
    );
  }

  Future<void> deleteUser(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deleteUser',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('user_id', id);
      },
    );
  }
}

