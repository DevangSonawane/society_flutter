import 'package:equatable/equatable.dart';

enum InvoiceStatus { pending, paid, overdue }

class VendorInvoiceModel extends Equatable {
  final String id;
  final String vendorId;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final List<InvoiceItem> items; // JSONB array
  final double subtotal;
  final double tax;
  final double total;
  final InvoiceStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VendorInvoiceModel({
    required this.id,
    required this.vendorId,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        vendorId,
        invoiceNumber,
        invoiceDate,
        dueDate,
        items,
        subtotal,
        tax,
        total,
        status,
        notes,
        createdAt,
        updatedAt,
      ];

  factory VendorInvoiceModel.fromJson(Map<String, dynamic> json) {
    return VendorInvoiceModel(
      id: json['id'] as String,
      vendorId: json['vendor_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      invoiceDate: DateTime.parse(json['invoice_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      status: _invoiceStatusFromString(json['status'] as String? ?? 'pending'),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static InvoiceStatus _invoiceStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return InvoiceStatus.paid;
      case 'overdue':
        return InvoiceStatus.overdue;
      case 'pending':
      default:
        return InvoiceStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendorId,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String().split('T')[0],
      'due_date': dueDate.toIso8601String().split('T')[0],
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': _invoiceStatusToString(status),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
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

class InvoiceItem extends Equatable {
  final int srNo;
  final String description;
  final double charges;

  const InvoiceItem({
    required this.srNo,
    required this.description,
    required this.charges,
  });

  @override
  List<Object?> get props => [srNo, description, charges];

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      srNo: json['srNo'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      charges: (json['charges'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'srNo': srNo,
      'description': description,
      'charges': charges,
    };
  }
}

