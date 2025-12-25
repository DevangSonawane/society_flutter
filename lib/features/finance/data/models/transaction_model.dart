import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

enum TransactionSource { maintenance, vendor, deposit, roomCharge, manual }

class TransactionModel extends Equatable {
  final String id;
  final String description;
  final double amount;
  final TransactionType type;
  final String? category;
  final DateTime createdAt;
  final String? referenceNumber;
  final String? paidBy;
  final String? paidTo;
  final TransactionSource? source;
  final String? sourceId;

  const TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    this.category,
    required this.createdAt,
    this.referenceNumber,
    this.paidBy,
    this.paidTo,
    this.source,
    this.sourceId,
  });

  @override
  List<Object?> get props => [
        id,
        description,
        amount,
        type,
        category,
        createdAt,
        referenceNumber,
        paidBy,
        paidTo,
        source,
        sourceId,
      ];

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Handle date parsing with multiple fallbacks
    DateTime parseDate() {
      try {
        if (json['transaction_date'] != null) {
          final dateValue = json['transaction_date'];
          if (dateValue is String) {
            return DateTime.parse(dateValue);
          } else if (dateValue is DateTime) {
            return dateValue;
          }
        }
      } catch (e) {
        // Try next fallback
      }
      
      try {
        if (json['created_at'] != null) {
          final dateValue = json['created_at'];
          if (dateValue is String) {
            return DateTime.parse(dateValue);
          } else if (dateValue is DateTime) {
            return dateValue;
          }
        }
      } catch (e) {
        // Try next fallback
      }
      
      try {
        if (json['createdAt'] != null) {
          final dateValue = json['createdAt'];
          if (dateValue is String) {
            return DateTime.parse(dateValue);
          } else if (dateValue is DateTime) {
            return dateValue;
          }
        }
      } catch (e) {
        // Use current date as fallback
      }
      
      // Final fallback to current date
      return DateTime.now();
    }
    
    return TransactionModel(
      id: json['id'] as String? ?? json['transaction_id'] as String? ?? '',
      description: json['description'] as String? ?? json['desc'] as String? ?? 'No description',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: _transactionTypeFromString(json['type'] as String? ?? 'credit'),
      category: json['category'] as String?,
      createdAt: parseDate(),
      referenceNumber: json['reference_number'] as String? ?? json['referenceNumber'] as String?,
      paidBy: json['paid_by'] as String? ?? json['paidBy'] as String?,
      paidTo: json['paid_to'] as String? ?? json['paidTo'] as String?,
      source: _transactionSourceFromString(json['source'] as String?),
      sourceId: json['source_id'] as String? ?? json['sourceId'] as String?,
    );
  }

  static TransactionType _transactionTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return TransactionType.credit;
      case 'debit':
        return TransactionType.debit;
      default:
        return TransactionType.credit;
    }
  }

  static TransactionSource? _transactionSourceFromString(String? source) {
    if (source == null) return null;
    switch (source.toLowerCase()) {
      case 'maintenance':
        return TransactionSource.maintenance;
      case 'vendor':
        return TransactionSource.vendor;
      case 'deposit':
        return TransactionSource.deposit;
      case 'room_charge':
      case 'roomcharge':
        return TransactionSource.roomCharge;
      case 'manual':
        return TransactionSource.manual;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type.name,
      'category': category,
      'transaction_date': createdAt.toIso8601String(),
      'reference_number': referenceNumber,
      'paid_by': paidBy,
      'paid_to': paidTo,
      'source': source?.name,
      'source_id': sourceId,
    };
  }
}

