import '../data/models/transaction_model.dart';
import '../data/models/vendor_invoice_model.dart';
import '../data/models/billing_history_model.dart';
import '../../maintenance_payments/data/models/maintenance_payment_model.dart';
import '../../vendors/data/models/vendor_model.dart';
import '../../expenses_charges/data/models/deposit_model.dart';
import '../../expenses_charges/data/models/society_room_model.dart';

class FinanceAggregatorService {
  /// Convert maintenance payments to transactions
  /// Format: "Maintenance Payment - Flat {flatNumber} - {month}/{year}"
  static List<TransactionModel> convertMaintenancePayments(List<MaintenancePaymentModel> payments) {
    return payments
        .where((payment) => payment.status == PaymentStatus.paid)
        .map((payment) {
          // Format: "Maintenance Payment - Flat {flatNumber} - {month}/{year}"
          final description = 'Maintenance Payment - Flat ${payment.flatNumber} - ${payment.month}/${payment.year}';
          
          // Use paidDate if available, otherwise use createdAt
          // Include lateFee in the amount if applicable
          final transactionDate = payment.paidDate ?? payment.createdAt;
          final totalAmount = payment.amount + (payment.lateFee);
          
          return TransactionModel(
            id: 'maintenance_${payment.id}',
            description: description,
            amount: totalAmount,
            type: TransactionType.credit,
            category: 'maintenance',
            createdAt: transactionDate,
            referenceNumber: payment.receiptNumber ?? payment.id,
            paidBy: payment.residentId ?? payment.residentName,
            source: TransactionSource.maintenance,
            sourceId: payment.id,
          );
        })
        .toList();
  }

  /// Convert vendor invoices to expense transactions
  /// Format: "Vendor Invoice - {invoiceNumber} - {vendorName}"
  static List<TransactionModel> convertVendorInvoices(
    List<VendorInvoiceModel> invoices,
    Map<String, String> vendorIdToNameMap,
  ) {
    return invoices.map((invoice) {
      final vendorName = vendorIdToNameMap[invoice.vendorId] ?? 'Unknown Vendor';
      final description = 'Vendor Invoice - ${invoice.invoiceNumber} - $vendorName';
      
      return TransactionModel(
        id: 'invoice_${invoice.id}',
        description: description,
        amount: invoice.total,
        type: TransactionType.debit,
        category: 'vendor',
        createdAt: invoice.invoiceDate,
        referenceNumber: invoice.invoiceNumber,
        paidTo: vendorName,
        source: TransactionSource.vendor,
        sourceId: invoice.id,
      );
    }).toList();
  }

  /// Convert billing history (vendor payments) to transactions
  /// Format: "Vendor Payment - {vendorName} - {invoiceNumber if available}"
  static List<TransactionModel> convertBillingHistory(
    List<BillingHistoryModel> billingHistory,
    Map<String, String> vendorIdToNameMap,
    Map<String, String> invoiceIdToNumberMap,
  ) {
    return billingHistory.map((payment) {
      final vendorName = payment.vendorId != null 
          ? (vendorIdToNameMap[payment.vendorId] ?? 'Unknown Vendor')
          : 'Unknown Vendor';
      
      String invoiceRef = '';
      if (payment.invoiceId != null) {
        invoiceRef = invoiceIdToNumberMap[payment.invoiceId] ?? payment.invoiceId!.substring(0, 8);
      }
      
      final description = invoiceRef.isNotEmpty
          ? 'Vendor Payment - $vendorName - $invoiceRef'
          : 'Vendor Payment - $vendorName';
      
      return TransactionModel(
        id: 'billing_${payment.id}',
        description: description,
        amount: payment.amountPaid,
        type: TransactionType.debit,
        category: 'vendor',
        createdAt: payment.paymentDate,
        referenceNumber: payment.id,
        paidTo: vendorName,
        source: TransactionSource.vendor,
        sourceId: payment.id,
      );
    }).toList();
  }

  /// Convert deposits to transactions
  /// Format: "Deposit on Renovation - Flat {flatNumber}" (credit)
  /// Format: "Deposit Refund - Flat {flatNumber}" (debit)
  static List<TransactionModel> convertDeposits(List<DepositModel> deposits) {
    final transactions = <TransactionModel>[];
    
    for (final deposit in deposits) {
      // Create credit transaction for collected deposits (not pending)
      // This includes both active deposits and refunded deposits (since they were collected first)
      if (deposit.status != DepositStatus.pending) {
        transactions.add(TransactionModel(
          id: 'deposit_credit_${deposit.id}',
          description: 'Deposit on Renovation - Flat ${deposit.flatNumber}',
          amount: deposit.amount,
          type: TransactionType.credit,
          category: 'deposit',
          createdAt: deposit.depositDate,
          referenceNumber: deposit.id,
          paidBy: deposit.residentId ?? deposit.ownerName,
          source: TransactionSource.deposit,
          sourceId: deposit.id,
        ));
      }
      
      // Create debit transaction for refunded deposits
      // Format: "Deposit Refund - Flat {flatNumber}"
      if (deposit.status == DepositStatus.refunded) {
        transactions.add(TransactionModel(
          id: 'deposit_debit_${deposit.id}',
          description: 'Deposit Refund - Flat ${deposit.flatNumber}',
          amount: deposit.amount,
          type: TransactionType.debit,
          category: 'deposit_refund',
          createdAt: deposit.updatedAt ?? deposit.depositDate,
          referenceNumber: deposit.id,
          paidBy: deposit.residentId ?? deposit.ownerName,
          source: TransactionSource.deposit,
          sourceId: deposit.id,
        ));
      }
    }
    
    return transactions;
  }

  /// Convert society room charges to transactions
  /// Format: "Room Charge - {roomNumber} - {month}/{year}"
  static List<TransactionModel> convertRoomCharges(List<SocietyRoomModel> rooms) {
    return rooms
        .where((room) => 
          room.status == RoomStatus.occupied && 
          room.financeMoney != null && 
          room.financeMoney! > 0 &&
          room.financeMonth != null)
        .map((room) {
          // Format: "Room Charge - {roomNumber} - {month}/{year}"
          final currentYear = DateTime.now().year;
          final description = 'Room Charge - ${room.roomNumber} - ${room.financeMonth}/$currentYear';
          
          // Use updatedAt if available (when charge was set), otherwise createdAt
          final transactionDate = room.updatedAt ?? room.createdAt;
          
          return TransactionModel(
            id: 'room_${room.id}_${room.financeMonth}_$currentYear',
            description: description,
            amount: room.financeMoney!,
            type: TransactionType.credit,
            category: 'room_charge',
            createdAt: transactionDate,
            referenceNumber: room.id,
            source: TransactionSource.roomCharge,
            sourceId: room.id,
          );
        })
        .toList();
  }

  /// Aggregate all transactions from all sources
  static List<TransactionModel> aggregateTransactions({
    required List<MaintenancePaymentModel> maintenancePayments,
    required List<VendorInvoiceModel> vendorInvoices,
    required List<BillingHistoryModel> billingHistory,
    required List<VendorModel> vendors, // Still needed for vendor name mapping
    required List<DepositModel> deposits,
    required List<SocietyRoomModel> rooms,
  }) {
    final allTransactions = <TransactionModel>[];
    
    // Create vendor ID to name mapping
    final vendorIdToNameMap = <String, String>{};
    for (final vendor in vendors) {
      vendorIdToNameMap[vendor.id] = vendor.vendorName;
    }
    
    // Create invoice ID to invoice number mapping
    final invoiceIdToNumberMap = <String, String>{};
    for (final invoice in vendorInvoices) {
      invoiceIdToNumberMap[invoice.id] = invoice.invoiceNumber;
    }
    
    // Add maintenance payment transactions (credits)
    allTransactions.addAll(convertMaintenancePayments(maintenancePayments));
    
    // Add vendor invoice transactions (debits - expenses)
    allTransactions.addAll(convertVendorInvoices(vendorInvoices, vendorIdToNameMap));
    
    // Add vendor payment transactions from billing history (debits)
    allTransactions.addAll(convertBillingHistory(billingHistory, vendorIdToNameMap, invoiceIdToNumberMap));
    
    // Add deposit transactions (credits and debits)
    allTransactions.addAll(convertDeposits(deposits));
    
    // Add room charge transactions (credits)
    allTransactions.addAll(convertRoomCharges(rooms));
    
    // Sort by date (newest first)
    allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return allTransactions;
  }
}

