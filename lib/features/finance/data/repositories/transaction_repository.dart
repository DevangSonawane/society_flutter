import '../models/transaction_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class TransactionRepository {
  final String _table = 'transactions';

  Future<List<TransactionModel>> getTransactions() async {
    return SupabaseService.executeQuery<List<TransactionModel>>(
      context: 'getTransactions',
      query: () async {
        try {
          // Try ordering by transaction_date first, fallback to created_at
          dynamic response;
          try {
            response = await SupabaseService.client
                .from(_table)
                .select()
                .order('transaction_date', ascending: false);
          } catch (e) {
            // If transaction_date doesn't exist, try created_at
            LoggerService.warning('transaction_date column not found, trying created_at');
            response = await SupabaseService.client
                .from(_table)
                .select()
                .order('created_at', ascending: false);
          }
          
          if (response == null) {
            LoggerService.warning('getTransactions: Response is null');
            return [];
          }
          
          if (response is! List) {
            LoggerService.warning('getTransactions: Response is not a list: ${response.runtimeType}');
            return [];
          }
          
          final responseList = response;
          if (responseList.isEmpty) {
            LoggerService.info('getTransactions: No transactions found');
            return [];
          }
          
          return responseList
              .map((json) {
                try {
                  return TransactionModel.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  LoggerService.error('Error parsing transaction: $json', e);
                  rethrow;
                }
              })
              .toList();
        } catch (e) {
          LoggerService.error('Error in getTransactions query', e);
          rethrow;
        }
      },
    );
  }

  Future<List<TransactionModel>> getTransactionsByType(TransactionType type) async {
    return SupabaseService.executeQuery<List<TransactionModel>>(
      context: 'getTransactionsByType',
      query: () async {
        dynamic response;
        try {
          response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('type', type.name)
              .order('transaction_date', ascending: false);
        } catch (e) {
          LoggerService.warning('transaction_date column not found, trying created_at');
          response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('type', type.name)
              .order('created_at', ascending: false);
        }
        
        return (response as List)
            .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<TransactionModel>> getTransactionsBySource(TransactionSource source) async {
    return SupabaseService.executeQuery<List<TransactionModel>>(
      context: 'getTransactionsBySource',
      query: () async {
        dynamic response;
        try {
          response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('source', source.name)
              .order('transaction_date', ascending: false);
        } catch (e) {
          LoggerService.warning('transaction_date column not found, trying created_at');
          response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('source', source.name)
              .order('created_at', ascending: false);
        }
        
        return (response as List)
            .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<TransactionModel>> getTransactionsByCategory(String category) async {
    return SupabaseService.executeQuery<List<TransactionModel>>(
      context: 'getTransactionsByCategory',
      query: () async {
        dynamic response;
        try {
          response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('category', category)
              .order('transaction_date', ascending: false);
        } catch (e) {
          LoggerService.warning('transaction_date column not found, trying created_at');
          response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('category', category)
              .order('created_at', ascending: false);
        }
        
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

