import 'package:equatable/equatable.dart';

enum DepositStatus { pending, refunded, forfeited }

class DepositModel extends Equatable {
  final String id;
  final String? residentId;
  final String flatNumber;
  final double amount;
  final DateTime depositDate;
  final DepositStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String residentName;
  final String? ownerName;
  final String? phoneNumber;

  const DepositModel({
    required this.id,
    this.residentId,
    required this.flatNumber,
    required this.residentName,
    required this.amount,
    required this.depositDate,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.ownerName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [
        id,
        residentId,
        flatNumber,
        residentName,
        amount,
        depositDate,
        status,
        notes,
        createdAt,
        updatedAt,
        ownerName,
        phoneNumber,
      ];

  factory DepositModel.fromJson(Map<String, dynamic> json) {
    return DepositModel(
      id: json['id'] as String,
      residentId: json['resident_id'] as String?,
      flatNumber: json['flat_number'] as String,
      residentName: json['resident_name'] as String? ?? json['owner_name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      depositDate: DateTime.parse(json['deposit_date'] as String),
      status: _depositStatusFromString(json['status'] as String? ?? 'pending'),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      ownerName: json['owner_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  static DepositStatus _depositStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'refunded':
        return DepositStatus.refunded;
      case 'forfeited':
        return DepositStatus.forfeited;
      case 'pending':
      default:
        return DepositStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resident_id': residentId,
      'flat_number': flatNumber,
      'resident_name': residentName,
      'amount': amount,
      'deposit_date': depositDate.toIso8601String().split('T')[0],
      'status': status.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'owner_name': ownerName,
      'phone_number': phoneNumber,
    };
  }
}

