import '../models/transaction_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class TransactionRepository {
  final String _table = 'transactions';

  Future<List<TransactionModel>> getTransactions() async {
    return SupabaseService.executeQuery<List<TransactionModel>>(
      context: 'getTransactions',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .order('transaction_date', ascending: false);
        
        return (response as List)
            .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<TransactionModel>> getTransactionsByType(TransactionType type) async {
    return SupabaseService.executeQuery<List<TransactionModel>>(
      context: 'getTransactionsByType',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .eq('type', type.name)
            .order('transaction_date', ascending: false);
        
        return (response as List)
            .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      return SupabaseService.executeQuery<TransactionModel>(
        context: 'getTransactionById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return TransactionModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('Transaction not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    return SupabaseService.executeQuery<TransactionModel>(
      context: 'createTransaction',
      query: () async {
        final data = transaction.toJson();
        data.remove('id');
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        return TransactionModel.fromJson(response);
      },
    );
  }

  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    return SupabaseService.executeQuery<TransactionModel>(
      context: 'updateTransaction',
      query: () async {
        final data = transaction.toJson();
        data.remove('id');
        
        final response = await SupabaseService.client
            .from(_table)
            .update(data)
            .eq('id', transaction.id)
            .select()
            .single();
        
        return TransactionModel.fromJson(response);
      },
    );
  }

  Future<void> deleteTransaction(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deleteTransaction',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('id', id);
      },
    );
  }
}

