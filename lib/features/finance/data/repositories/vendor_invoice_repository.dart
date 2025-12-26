import '../models/vendor_invoice_model.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/logger_service.dart';

class VendorInvoiceRepository {
  final String _table = 'vendor_invoices';

  Future<List<VendorInvoiceModel>> getVendorInvoices() async {
    return SupabaseService.executeQuery<List<VendorInvoiceModel>>(
      context: 'getVendorInvoices',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .order('invoice_date', ascending: false);
        
        return (response as List)
            .map((json) => VendorInvoiceModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<VendorInvoiceModel?> getInvoiceById(String id) async {
    try {
      return SupabaseService.executeQuery<VendorInvoiceModel>(
        context: 'getInvoiceById',
        query: () async {
          final response = await SupabaseService.client
              .from(_table)
              .select()
              .eq('id', id)
              .single();
          
          return VendorInvoiceModel.fromJson(response);
        },
      );
    } catch (e) {
      if (e.toString().contains('PGRST116') || e.toString().contains('not found')) {
        LoggerService.warning('Invoice not found with id: $id');
        return null;
      }
      rethrow;
    }
  }

  Future<List<VendorInvoiceModel>> getInvoicesByVendor(String vendorId) async {
    return SupabaseService.executeQuery<List<VendorInvoiceModel>>(
      context: 'getInvoicesByVendor',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .select()
            .eq('vendor_id', vendorId)
            .order('invoice_date', ascending: false);
        
        return (response as List)
            .map((json) => VendorInvoiceModel.fromJson(json as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<VendorInvoiceModel> createInvoice(VendorInvoiceModel invoice) async {
    return SupabaseService.executeQuery<VendorInvoiceModel>(
      context: 'createInvoice',
      query: () async {
        final data = invoice.toJson();
        data.remove('id');
        data.remove('created_at');
        data.remove('updated_at');
        
        final response = await SupabaseService.client
            .from(_table)
            .insert(data)
            .select()
            .single();
        
        return VendorInvoiceModel.fromJson(response);
      },
    );
  }

  Future<VendorInvoiceModel> updateInvoice(VendorInvoiceModel invoice) async {
    return SupabaseService.executeQuery<VendorInvoiceModel>(
      context: 'updateInvoice',
      query: () async {
        final data = invoice.toJson();
        data.remove('created_at');
        data['updated_at'] = DateTime.now().toIso8601String();
        
        final response = await SupabaseService.client
            .from(_table)
            .update(data)
            .eq('id', invoice.id)
            .select()
            .single();
        
        return VendorInvoiceModel.fromJson(response);
      },
    );
  }

  Future<VendorInvoiceModel> updateInvoiceStatus(String id, InvoiceStatus status) async {
    return SupabaseService.executeQuery<VendorInvoiceModel>(
      context: 'updateInvoiceStatus',
      query: () async {
        final response = await SupabaseService.client
            .from(_table)
            .update({
              'status': _invoiceStatusToString(status),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', id)
            .select()
            .single();
        
        return VendorInvoiceModel.fromJson(response);
      },
    );
  }

  Future<void> deleteInvoice(String id) async {
    await SupabaseService.executeQuery<void>(
      context: 'deleteInvoice',
      query: () async {
        await SupabaseService.client
            .from(_table)
            .delete()
            .eq('id', id);
      },
    );
  }

  String _invoiceStatusToString(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return 'paid';
      case InvoiceStatus.overdue:
        return 'overdue';
      case InvoiceStatus.pending:
        return 'pending';
    }
  }
}

