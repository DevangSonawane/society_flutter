import '../models/vendor_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class VendorRepository {
  final String _table = 'vendors';

  Future<List<VendorModel>> getVendors() async {
    return SupabaseService.executeQuery<List<VendorModel>>(
      context: 'getVendors',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .order('created_at', ascending: false);
        
        return (response as List)
            .map((json) => VendorModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<VendorModel?> getVendorById(String id) async {
    try {
      return SupabaseService.executeQuery<VendorModel>(
        context: 'getVendorById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return VendorModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('Vendor not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<VendorModel> createVendor(VendorModel vendor) async {
    return SupabaseService.executeQuery<VendorModel>(
      context: 'createVendor',
      query: () async {
        final data = vendor.toJson();
        data.remove('id');
        data.remove('created_at');
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        return VendorModel.fromJson(response);
      },
    );
  }

  Future<VendorModel> updateVendor(VendorModel vendor) async {
    return SupabaseService.executeQuery<VendorModel>(
      context: 'updateVendor',
      query: () async {
        final data = vendor.toJson();
        data.remove('created_at');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        final response = await SupabaseService.client
            .from(_table)
            .update(data)
            .eq('id', vendor.id)
            .select()
            .single();
        
        return VendorModel.fromJson(response);
      },
    );
  }

  Future<void> deleteVendor(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deleteVendor',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('id', id);
      },
    );
  }
}

