import 'package:equatable/equatable.dart';

class BillingHistoryModel extends Equatable {
  final String id;
  final String? vendorId;
  final String? invoiceId;
  final double amountPaid;
  final DateTime paymentDate;
  final String? paymentMode;
  final String? paymentDetails;
  final DateTime? paymentTimestamp;
  final DateTime createdAt;

  const BillingHistoryModel({
    required this.id,
    this.vendorId,
    this.invoiceId,
    required this.amountPaid,
    required this.paymentDate,
    this.paymentMode,
    this.paymentDetails,
    this.paymentTimestamp,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        vendorId,
        invoiceId,
        amountPaid,
        paymentDate,
        paymentMode,
        paymentDetails,
        paymentTimestamp,
        createdAt,
      ];

  factory BillingHistoryModel.fromJson(Map<String, dynamic> json) {
    return BillingHistoryModel(
      id: json['id'] as String,
      vendorId: json['vendor_id'] as String?,
      invoiceId: json['invoice_id'] as String?,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      paymentDate: DateTime.parse(json['payment_date'] as String),
      paymentMode: json['payment_mode'] as String?,
      paymentDetails: json['payment_details'] as String?,
      paymentTimestamp: json['payment_timestamp'] != null
          ? DateTime.parse(json['payment_timestamp'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'invoice_id': invoiceId,
      'amount_paid': amountPaid,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'payment_mode': paymentMode,
      'payment_details': paymentDetails,
      'payment_timestamp': paymentTimestamp?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

