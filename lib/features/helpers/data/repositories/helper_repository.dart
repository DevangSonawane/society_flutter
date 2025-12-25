import '../models/helper_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class HelperRepository {
  final String _table = 'helpers';

  Future<List<HelperModel>> getHelpers() async {
    return SupabaseService.executeQuery<List<HelperModel>>(
      context: 'getHelpers',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .order('created_at', ascending: false);
        
        return (response as List)
            .map((json) => HelperModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<HelperModel?> getHelperById(String id) async {
    try {
      return SupabaseService.executeQuery<HelperModel>(
        context: 'getHelperById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return HelperModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('Helper not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<HelperModel> createHelper(HelperModel helper) async {
    return SupabaseService.executeQuery<HelperModel>(
      context: 'createHelper',
      query: () async {
        final data = helper.toJson();
        data.remove('id');
        data.remove('created_at');
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        return HelperModel.fromJson(response);
      },
    );
  }

  Future<HelperModel> updateHelper(HelperModel helper) async {
    return SupabaseService.executeQuery<HelperModel>(
      context: 'updateHelper',
      query: () async {
        final data = helper.toJson();
        data.remove('created_at');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        final response = await SupabaseService.client
            .from(_table)
            .update(data)
            .eq('id', helper.id)
            .select()
            .single();
        
        return HelperModel.fromJson(response);
      },
    );
  }

  Future<void> deleteHelper(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deleteHelper',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('id', id);
      },
    );
  }
}

