import '../models/complaint_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class ComplaintRepository {
  final String _table = 'complaints';

  Future<List<ComplaintModel>> getComplaints() async {
    return SupabaseService.executeQuery<List<ComplaintModel>>(
      context: 'getComplaints',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .order('created_at', ascending: false);
        
        return (response as List)
            .map((json) => ComplaintModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<ComplaintModel?> getComplaintById(String id) async {
    try {
      return SupabaseService.executeQuery<ComplaintModel>(
        context: 'getComplaintById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return ComplaintModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('Complaint not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<ComplaintModel> createComplaint(ComplaintModel complaint) async {
    return SupabaseService.executeQuery<ComplaintModel>(
      context: 'createComplaint',
      query: () async {
        final data = complaint.toJson();
        data.remove('id');
        data.remove('created_at');
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        return ComplaintModel.fromJson(response);
      },
    );
  }

  Future<ComplaintModel> updateComplaint(ComplaintModel complaint) async {
    return SupabaseService.executeQuery<ComplaintModel>(
      context: 'updateComplaint',
      query: () async {
        final data = complaint.toJson();
        data.remove('created_at');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        final response = await SupabaseService.client
            .from(_table)
            .update(data)
            .eq('id', complaint.id)
            .select()
            .single();
        
        return ComplaintModel.fromJson(response);
      },
    );
  }

  Future<void> deleteComplaint(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deleteComplaint',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('id', id);
      },
    );
  }
}

