import 'package:equatable/equatable.dart';

enum PaymentStatus { unpaid, paid, overdue, partial }

class MaintenancePaymentModel extends Equatable {
  final String id;
  final String flatNumber;
  final String residentName;
  final int month;
  final int year;
  final double amount;
  final PaymentStatus status;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? paymentMethod;
  final String? receiptNumber;
  final double lateFee;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? residentId;

  const MaintenancePaymentModel({
    required this.id,
    required this.flatNumber,
    required this.residentName,
    required this.month,
    required this.year,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.paidDate,
    this.paymentMethod,
    this.receiptNumber,
    this.lateFee = 0.0,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.residentId,
  });

  @override
  List<Object?> get props => [
        id,
        flatNumber,
        residentName,
        month,
        year,
        amount,
        status,
        dueDate,
        paidDate,
        paymentMethod,
        receiptNumber,
        lateFee,
        notes,
        createdAt,
        updatedAt,
        residentId,
      ];

  factory MaintenancePaymentModel.fromJson(Map<String, dynamic> json) {
    return MaintenancePaymentModel(
      id: json['id'] as String,
      flatNumber: json['flat_number'] as String,
      residentName: json['resident_name'] as String,
      month: json['month'] as int,
      year: json['year'] as int,
      amount: (json['amount'] as num?)?.toDouble() ?? 2000.0,
      status: _paymentStatusFromString(json['status'] as String? ?? 'unpaid'),
      dueDate: DateTime.parse(json['due_date'] as String),
      paidDate: json['paid_date'] != null 
          ? DateTime.parse(json['paid_date'] as String)
          : null,
      paymentMethod: json['payment_method'] as String?,
      receiptNumber: json['receipt_number'] as String?,
      lateFee: (json['late_fee'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      residentId: json['resident_id'] as String?,
    );
  }

  static PaymentStatus _paymentStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return PaymentStatus.paid;
      case 'overdue':
        return PaymentStatus.overdue;
      case 'partial':
        return PaymentStatus.partial;
      case 'unpaid':
      default:
        return PaymentStatus.unpaid;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flat_number': flatNumber,
      'resident_name': residentName,
      'month': month,
      'year': year,
      'amount': amount,
      'status': status.name,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'paid_date': paidDate?.toIso8601String().split('T')[0],
      'payment_method': paymentMethod,
      'receipt_number': receiptNumber,
      'late_fee': lateFee,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'resident_id': residentId,
    };
  }
}

