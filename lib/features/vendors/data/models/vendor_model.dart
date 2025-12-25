import 'package:equatable/equatable.dart';

class VendorModel extends Equatable {
  final String id;
  final String vendorName;
  final String email;
  final String phoneNumber;
  final String? workDetails;
  final double totalBill;
  final double paidBill;
  final double outstandingBill;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const VendorModel({
    required this.id,
    required this.vendorName,
    required this.email,
    required this.phoneNumber,
    this.workDetails,
    required this.totalBill,
    required this.paidBill,
    required this.outstandingBill,
    required this.createdAt,
    this.updatedAt,
  });

  // Convenience getters for backward compatibility
  String get name => vendorName;
  String? get phone => phoneNumber;
  String? get workType => workDetails;
  double get paidAmount => paidBill;
  String get status => 'Active'; // Default status, can be extended later

  @override
  List<Object?> get props => [
        id,
        vendorName,
        email,
        phoneNumber,
        workDetails,
        totalBill,
        paidBill,
        outstandingBill,
        createdAt,
        updatedAt,
      ];

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] as String,
      vendorName: json['vendor_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      workDetails: json['work_details'] as String?,
      totalBill: (json['total_bill'] as num?)?.toDouble() ?? 0.0,
      paidBill: (json['paid_bill'] as num?)?.toDouble() ?? 0.0,
      outstandingBill: (json['outstanding_bill'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_name': vendorName,
      'email': email,
      'phone_number': phoneNumber,
      'work_details': workDetails,
      'total_bill': totalBill,
      'paid_bill': paidBill,
      'outstanding_bill': outstandingBill,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

