import '../data/models/transaction_model.dart';
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

  /// Convert vendor payments to transactions
  /// Format: "Vendor Payment - {vendorName} - {invoiceNumber}"
  /// Note: Since we don't have separate invoice tracking, we use vendor ID as reference
  static List<TransactionModel> convertVendorPayments(List<VendorModel> vendors) {
    return vendors
        .where((vendor) => vendor.paidBill > 0)
        .map((vendor) {
          // Format: "Vendor Payment - {vendorName} - {invoiceNumber}"
          // Use vendor ID as invoice number since we don't have separate invoice tracking
          final invoiceRef = vendor.id.length > 8 ? vendor.id.substring(0, 8) : vendor.id;
          final description = 'Vendor Payment - ${vendor.vendorName} - $invoiceRef';
          
          // Use updatedAt if available (when payment was made), otherwise createdAt
          final transactionDate = vendor.updatedAt ?? vendor.createdAt;
          
          return TransactionModel(
            id: 'vendor_${vendor.id}',
            description: description,
            amount: vendor.paidBill,
            type: TransactionType.debit,
            category: 'vendor',
            createdAt: transactionDate,
            referenceNumber: invoiceRef,
            paidTo: vendor.vendorName,
            source: TransactionSource.vendor,
            sourceId: vendor.id,
          );
        })
        .toList();
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
    required List<VendorModel> vendors,
    required List<DepositModel> deposits,
    required List<SocietyRoomModel> rooms,
  }) {
    final allTransactions = <TransactionModel>[];
    
    // Add maintenance payment transactions (credits)
    allTransactions.addAll(convertMaintenancePayments(maintenancePayments));
    
    // Add vendor payment transactions (debits)
    allTransactions.addAll(convertVendorPayments(vendors));
    
    // Add deposit transactions (credits and debits)
    allTransactions.addAll(convertDeposits(deposits));
    
    // Add room charge transactions (credits)
    allTransactions.addAll(convertRoomCharges(rooms));
    
    // Sort by date (newest first)
    allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return allTransactions;
  }
}

