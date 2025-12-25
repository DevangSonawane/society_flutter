import '../models/society_room_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class SocietyRoomRepository {
  final String _table = 'society_owned_rooms';

  Future<List<SocietyRoomModel>> getRooms() async {
    return SupabaseService.executeQuery<List<SocietyRoomModel>>(
      context: 'getRooms',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .order('created_at', ascending: false);
        
        return (response as List)
            .map((json) => SocietyRoomModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<SocietyRoomModel?> getRoomById(String id) async {
    try {
      return SupabaseService.executeQuery<SocietyRoomModel>(
        context: 'getRoomById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return SocietyRoomModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('Room not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<SocietyRoomModel> createRoom(SocietyRoomModel room) async {
    return SupabaseService.executeQuery<SocietyRoomModel>(
      context: 'createRoom',
      query: () async {
        final data = room.toJson();
        data.remove('id');
        data.remove('created_at');
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        return SocietyRoomModel.fromJson(response);
      },
    );
  }

  Future<SocietyRoomModel> updateRoom(SocietyRoomModel room) async {
    return SupabaseService.executeQuery<SocietyRoomModel>(
      context: 'updateRoom',
      query: () async {
        final data = room.toJson();
        data.remove('created_at');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        final response = await SupabaseService.client
            .from(_table)
            .update(data)
            .eq('id', room.id)
            .select()
            .single();
        
        return SocietyRoomModel.fromJson(response);
      },
    );
  }

  Future<void> deleteRoom(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deleteRoom',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('id', id);
      },
    );
  }
}

