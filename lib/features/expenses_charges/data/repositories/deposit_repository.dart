import '../models/deposit_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class DepositRepository {
  final String _table = 'deposite_on_renovation';

  Future<List<DepositModel>> getDeposits() async {
    return SupabaseService.executeQuery<List<DepositModel>>(
      context: 'getDeposits',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .order('created_at', ascending: false);
        
        return (response as List)
            .map((json) => DepositModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<DepositModel?> getDepositById(String id) async {
    try {
      return SupabaseService.executeQuery<DepositModel>(
        context: 'getDepositById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return DepositModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('Deposit not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<DepositModel> createDeposit(DepositModel deposit) async {
    return SupabaseService.executeQuery<DepositModel>(
      context: 'createDeposit',
      query: () async {
        final data = deposit.toJson();
        data.remove('id');
        data.remove('created_at');
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        return DepositModel.fromJson(response);
      },
    );
  }

  Future<DepositModel> updateDeposit(DepositModel deposit) async {
    return SupabaseService.executeQuery<DepositModel>(
      context: 'updateDeposit',
      query: () async {
        final data = deposit.toJson();
        data.remove('created_at');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        final response = await SupabaseService.client
            .from(_table)
            .update(data)
            .eq('id', deposit.id)
            .select()
            .single();
        
        return DepositModel.fromJson(response);
      },
    );
  }

  Future<void> deleteDeposit(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deleteDeposit',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('id', id);
      },
    );
  }
}

