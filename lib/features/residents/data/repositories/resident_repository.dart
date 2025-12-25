import '../models/resident_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class ResidentRepository {
  final String _table = 'residents';

  Future<List<ResidentModel>> getResidents() async {
    return SupabaseService.executeQuery<List<ResidentModel>>(
      context: 'getResidents',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .order('created_at', ascending: false);
        
        LoggerService.info('Fetched ${(response as List).length} residents');
        
        return (response as List)
            .map((json) {
              try {
                return ResidentModel.fromJson(json as Map<String, dynamic>);
              } catch (e, stackTrace) {
                LoggerService.error('Error parsing resident JSON', e, stackTrace);
                LoggerService.debug('Problematic JSON: $json');
                rethrow;
              }
            })
            .toList();
      },
    );
  }

  Future<ResidentModel?> getResidentById(String id) async {
    try {
      return SupabaseService.executeQuery<ResidentModel>(
        context: 'getResidentById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return ResidentModel.fromJson(response);
        },
      );
    } catch (e) {
      // Return null if not found, but throw for other errors
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('Resident not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<ResidentModel> createResident(ResidentModel resident) async {
    return SupabaseService.executeQuery<ResidentModel>(
      context: 'createResident',
      query: () async {
        final data = resident.toJson();
        data.remove('id');
        data.remove('created_at');
        
        LoggerService.debug('Creating resident with data: ${data.keys.toList()}');
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        LoggerService.info('Successfully created resident: ${response['id']}');
        return ResidentModel.fromJson(response);
      },
    );
  }

  Future<ResidentModel> updateResident(ResidentModel resident) async {
    return SupabaseService.executeQuery<ResidentModel>(
      context: 'updateResident',
      query: () async {
        final data = resident.toJson();
        data.remove('created_at');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        LoggerService.debug('Updating resident: ${resident.id}');
        
        final response = await SupabaseService.client
            .from(_table)
            .update(data)
            .eq('id', resident.id)
            .select()
            .single();
        
        LoggerService.info('Successfully updated resident: ${resident.id}');
        return ResidentModel.fromJson(response);
      },
    );
  }

  Future<void> deleteResident(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deleteResident',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('id', id);
        
        LoggerService.info('Successfully deleted resident: $id');
      },
    );
  }

  Future<List<ResidentModel>> searchResidents(String query) async {
    return SupabaseService.executeQuery<List<ResidentModel>>(
      context: 'searchResidents',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .or('owner_name.ilike.%$query%,flat_number.ilike.%$query%,phone_number.ilike.%$query%,email.ilike.%$query%')
            .order('created_at', ascending: false);
        
        return (response as List)
            .map((json) => ResidentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }
}

