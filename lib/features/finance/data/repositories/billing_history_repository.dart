import '../models/billing_history_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../vendors/data/repositories/vendor_repository.dart';
import '../../../vendors/data/models/vendor_model.dart';

class BillingHistoryRepository {
  final String _table = 'billing_history';
  final VendorRepository _vendorRepository = VendorRepository();

  Future<List<BillingHistoryModel>> getBillingHistory() async {
    return SupabaseService.executeQuery<List<BillingHistoryModel>>(
      context: 'getBillingHistory',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .order('payment_date', ascending: false);
        
        return (response as List)
            .map((json) => BillingHistoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<BillingHistoryModel?> getPaymentById(String id) async {
    try {
      return SupabaseService.executeQuery<BillingHistoryModel>(
        context: 'getPaymentById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return BillingHistoryModel.fromJson(response);
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

  Future<List<BillingHistoryModel>> getPaymentsByVendor(String vendorId) async {
    return SupabaseService.executeQuery<List<BillingHistoryModel>>(
      context: 'getPaymentsByVendor',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .eq('vendor_id', vendorId)
            .order('payment_date', ascending: false);
        
        return (response as List)
            .map((json) => BillingHistoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<List<BillingHistoryModel>> getPaymentsByInvoice(String invoiceId) async {
    return SupabaseService.executeQuery<List<BillingHistoryModel>>(
      context: 'getPaymentsByInvoice',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .eq('invoice_id', invoiceId)
            .order('payment_date', ascending: false);
        
        return (response as List)
            .map((json) => BillingHistoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<BillingHistoryModel> recordPayment(BillingHistoryModel payment) async {
    return SupabaseService.executeQuery<BillingHistoryModel>(
      context: 'recordPayment',
      query: () async {
        final data = payment.toJson();
        data.remove('id');
        data.remove('created_at');
        
        // Set payment_timestamp if not provided
        if (data['payment_timestamp'] == null) {
          data['payment_timestamp'] = DateTime.now().toIso8601String();
        }
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        final createdPayment = BillingHistoryModel.fromJson(response);
        
        // Update vendor balances if vendor_id is provided
        if (payment.vendorId != null) {
          await _updateVendorBalances(payment.vendorId!, payment.amountPaid);
        }
        
        return createdPayment;
      },
    );
  }

  Future<void> _updateVendorBalances(String vendorId, double amountPaid) async {
    try {
      // Get current vendor
      final vendor = await _vendorRepository.getVendorById(vendorId);
      if (vendor == null) {
        LoggerService.warning('Vendor not found for balance update: $vendorId');
        return;
      }
      
      // Calculate new balances
      final newPaidBill = vendor.paidBill + amountPaid;
      final newOutstandingBill = vendor.outstandingBill - amountPaid;
      
      // Ensure outstanding bill doesn't go negative
      final finalOutstandingBill = newOutstandingBill < 0 ? 0.0 : newOutstandingBill;
      
      // Update vendor
      final updatedVendor = VendorModel(
        id: vendor.id,
        vendorName: vendor.vendorName,
        email: vendor.email,
        phoneNumber: vendor.phoneNumber,
        workDetails: vendor.workDetails,
        totalBill: vendor.totalBill,
        paidBill: newPaidBill,
        outstandingBill: finalOutstandingBill,
        createdAt: vendor.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await _vendorRepository.updateVendor(updatedVendor);
      LoggerService.info('Updated vendor balances for vendor: $vendorId');
    } catch (e, stackTrace) {
      LoggerService.error('Error updating vendor balances', e, stackTrace);
      // Don't throw - payment was recorded successfully, balance update can be retried
    }
  }
}

