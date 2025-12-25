import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../residents/data/repositories/resident_repository.dart';
import '../../residents/data/models/resident_model.dart';
import '../../complaints/data/repositories/complaint_repository.dart';
import '../../complaints/data/models/complaint_model.dart';
import '../../permissions/data/repositories/permission_repository.dart';
import '../../permissions/data/models/permission_model.dart';
import '../../vendors/data/repositories/vendor_repository.dart';
import '../../vendors/data/models/vendor_model.dart';
import '../../helpers/data/repositories/helper_repository.dart';
import '../../helpers/data/models/helper_model.dart';
import '../../maintenance_payments/data/repositories/maintenance_payment_repository.dart';
import '../../maintenance_payments/data/models/maintenance_payment_model.dart';

class DashboardStats {
  final int totalResidents;
  final int totalComplaints;
  final int pendingComplaints;
  final int activePermissions;
  final int totalVendors;
  final int totalHelpers;
  final double totalMaintenanceCollection;
  final double pendingMaintenance;

  DashboardStats({
    required this.totalResidents,
    required this.totalComplaints,
    required this.pendingComplaints,
    required this.activePermissions,
    required this.totalVendors,
    required this.totalHelpers,
    required this.totalMaintenanceCollection,
    required this.pendingMaintenance,
  });
}

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final residentRepo = ResidentRepository();
  final complaintRepo = ComplaintRepository();
  final permissionRepo = PermissionRepository();
  final vendorRepo = VendorRepository();
  final helperRepo = HelperRepository();
  final maintenanceRepo = MaintenancePaymentRepository();

  // Fetch all data in parallel with error handling for each
  final results = await Future.wait([
    residentRepo.getResidents().catchError((e) => <ResidentModel>[]),
    complaintRepo.getComplaints().catchError((e) => <ComplaintModel>[]),
    permissionRepo.getPermissions().catchError((e) => <PermissionModel>[]),
    vendorRepo.getVendors().catchError((e) => <VendorModel>[]),
    helperRepo.getHelpers().catchError((e) => <HelperModel>[]),
    maintenanceRepo.getPayments().catchError((e) => <MaintenancePaymentModel>[]),
  ]);

  final residents = results[0] as List<ResidentModel>;
  final complaints = results[1] as List<ComplaintModel>;
  final permissions = results[2] as List<PermissionModel>;
  final vendors = results[3] as List<VendorModel>;
  final helpers = results[4] as List<HelperModel>;
  final maintenancePayments = results[5] as List<MaintenancePaymentModel>;

  // Calculate statistics
  final pendingComplaints = complaints.where((c) {
    final status = (c.status ?? '').toLowerCase();
    return status.contains('pending') || status.contains('in progress');
  }).length;

  final activePermissions = permissions.where((p) {
    final status = (p.status ?? '').toLowerCase();
    return status.contains('approved') || status.contains('pending');
  }).length;

  // Calculate maintenance collection
  double totalCollection = 0.0;
  double pendingAmount = 0.0;
  
  for (var payment in maintenancePayments) {
    totalCollection += payment.amount;
    if (payment.status.name == 'unpaid' || payment.status.name == 'overdue') {
      pendingAmount += payment.amount;
    }
  }

  return DashboardStats(
    totalResidents: residents.length,
    totalComplaints: complaints.length,
    pendingComplaints: pendingComplaints,
    activePermissions: activePermissions,
    totalVendors: vendors.length,
    totalHelpers: helpers.length,
    totalMaintenanceCollection: totalCollection,
    pendingMaintenance: pendingAmount,
  );
});

