import '../models/maintenance_payment_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class MaintenancePaymentRepository {
  final String _table = 'maintenance_payments';

  Future<List<MaintenancePaymentModel>> getPayments() async {
    return SupabaseService.executeQuery<List<MaintenancePaymentModel>>(
      context: 'getPayments',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .order('created_at', ascending: false);
        
        return (response as List)
            .map((json) => MaintenancePaymentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<MaintenancePaymentModel?> getPaymentById(String id) async {
    try {
      return SupabaseService.executeQuery<MaintenancePaymentModel>(
        context: 'getPaymentById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return MaintenancePaymentModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('Payment not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<MaintenancePaymentModel> createPayment(MaintenancePaymentModel payment) async {
    return SupabaseService.executeQuery<MaintenancePaymentModel>(
      context: 'createPayment',
      query: () async {
        final data = payment.toJson();
        data.remove('id');
        data.remove('created_at');
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        return MaintenancePaymentModel.fromJson(response);
      },
    );
  }

  Future<MaintenancePaymentModel> updatePayment(MaintenancePaymentModel payment) async {
    return SupabaseService.executeQuery<MaintenancePaymentModel>(
      context: 'updatePayment',
      query: () async {
        final data = payment.toJson();
        data.remove('created_at');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        final response = await SupabaseService.client
            .from(_table)
            .update(data)
            .eq('id', payment.id)
            .select()
            .single();
        
        return MaintenancePaymentModel.fromJson(response);
      },
    );
  }

  Future<void> deletePayment(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deletePayment',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('id', id);
      },
    );
  }

  Future<List<MaintenancePaymentModel>> generatePaymentsForMonth({
    required int month,
    required int year,
    required double amount,
    required List<Map<String, dynamic>> residents,
  }) async {
    return SupabaseService.executeQuery<List<MaintenancePaymentModel>>(
      context: 'generatePaymentsForMonth',
      query: () async {
        final dueDate = DateTime(year, month + 1, 1);
        final paymentsData = <Map<String, dynamic>>[];
        
        for (var resident in residents) {
          final paymentData = {
            'flat_number': resident['flatNumber'] ?? '',
            'resident_name': resident['ownerName'] ?? '',
            'month': month,
            'year': year,
            'amount': amount,
            'status': 'unpaid',
            'due_date': dueDate.toIso8601String().split('T')[0],
            'resident_id': resident['id'],
          };
          paymentsData.add(paymentData);
        }
        
        if (paymentsData.isEmpty) {
          return <MaintenancePaymentModel>[];
        }
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(paymentsData)
            .select();
        
        return (response as List)
            .map((json) => MaintenancePaymentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Get payments filtered by flat number (for residents)
  Future<List<MaintenancePaymentModel>> getPaymentsByFlatNumber(String flatNumber) async {
    return SupabaseService.executeQuery<List<MaintenancePaymentModel>>(
      context: 'getPaymentsByFlatNumber',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .eq('flat_number', flatNumber)
            .order('year', ascending: false)
            .order('month', ascending: false);
        
        return (response as List)
            .map((json) => MaintenancePaymentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }
}

