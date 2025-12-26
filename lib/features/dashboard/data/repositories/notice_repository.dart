import '../models/notice_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class NoticeRepository {
  final String _table = 'notices';

  Future<List<NoticeModel>> getNotices() async {
    return SupabaseService.executeQuery<List<NoticeModel>>(
      context: 'getNotices',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .eq('is_archived', false)
            .order('date', ascending: false);
        
        return (response as List)
            .map((json) => NoticeModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<NoticeModel?> getNoticeById(String id) async {
    try {
      return SupabaseService.executeQuery<NoticeModel>(
        context: 'getNoticeById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return NoticeModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('Notice not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<NoticeModel> createNotice(NoticeModel notice) async {
    return SupabaseService.executeQuery<NoticeModel>(
      context: 'createNotice',
      query: () async {
        final data = notice.toJson();
        data.remove('id');
        data.remove('created_at');
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        return NoticeModel.fromJson(response);
      },
    );
  }

  Future<NoticeModel> updateNotice(NoticeModel notice) async {
    return SupabaseService.executeQuery<NoticeModel>(
      context: 'updateNotice',
      query: () async {
        final data = notice.toJson();
        data.remove('created_at');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        final response = await SupabaseService.client
            .from(_table)
            .update(data)
            .eq('id', notice.id)
            .select()
            .single();
        
        return NoticeModel.fromJson(response);
      },
    );
  }

  Future<void> deleteNotice(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deleteNotice',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('id', id);
      },
    );
  }
}

