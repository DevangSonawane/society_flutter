import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction_model.dart';
import '../services/finance_aggregator_service.dart';
import '../../maintenance_payments/providers/maintenance_payments_provider.dart';
import '../../maintenance_payments/data/models/maintenance_payment_model.dart';
import '../../vendors/providers/vendors_provider.dart';
import '../../vendors/data/models/vendor_model.dart';
import '../../expenses_charges/providers/deposits_provider.dart';
import '../../expenses_charges/data/models/deposit_model.dart';
import '../../expenses_charges/providers/society_rooms_provider.dart';
import '../../expenses_charges/data/models/society_room_model.dart';

/// Aggregates transactions from all sources (maintenance, vendors, deposits, rooms)
final transactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  // Fetch data from all sources
  final maintenancePaymentsAsync = ref.watch(maintenancePaymentsProvider);
  final vendorsAsync = ref.watch(vendorsProvider);
  final depositsAsync = ref.watch(depositsProvider);
  final roomsAsync = ref.watch(societyRoomsProvider);
  
  // Extract data from AsyncValue, handling loading and errors
  List<MaintenancePaymentModel> maintenancePayments = [];
  List<VendorModel> vendors = [];
  List<DepositModel> deposits = [];
  List<SocietyRoomModel> rooms = [];
  
  maintenancePaymentsAsync.whenData((data) => maintenancePayments = data);
  vendorsAsync.whenData((data) => vendors = data);
  depositsAsync.whenData((data) => deposits = data);
  roomsAsync.whenData((data) => rooms = data);
  
  // If any are still loading, return empty list (will be updated when data loads)
  if (maintenancePaymentsAsync.isLoading || 
      vendorsAsync.isLoading || 
      depositsAsync.isLoading || 
      roomsAsync.isLoading) {
    return <TransactionModel>[];
  }
  
  // If any have errors, propagate the first error
  if (maintenancePaymentsAsync.hasError) {
    throw maintenancePaymentsAsync.error!;
  }
  if (vendorsAsync.hasError) {
    throw vendorsAsync.error!;
  }
  if (depositsAsync.hasError) {
    throw depositsAsync.error!;
  }
  if (roomsAsync.hasError) {
    throw roomsAsync.error!;
  }
  
  // Aggregate all transactions
  return FinanceAggregatorService.aggregateTransactions(
    maintenancePayments: maintenancePayments,
    vendors: vendors,
    deposits: deposits,
    rooms: rooms,
  );
});

/// Provider for manual transactions (created via "Make Payment" button)
/// These are stored separately and added to the aggregated list
final manualTransactionsProvider = StateNotifierProvider<ManualTransactionsNotifier, List<TransactionModel>>((ref) {
  return ManualTransactionsNotifier();
});

class ManualTransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  ManualTransactionsNotifier() : super([]);

  void addTransaction(TransactionModel transaction) {
    state = [...state, transaction];
  }

  void removeTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void clearTransactions() {
    state = [];
  }
}

/// Combined provider that includes both aggregated and manual transactions
final allTransactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  // Get aggregated transactions from all sources
  final aggregated = await ref.watch(transactionsProvider.future);
  
  // Get manual transactions
  final manual = ref.watch(manualTransactionsProvider);
  
  // Combine and sort by date
  final all = [...aggregated, ...manual];
  all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  return all;
});

