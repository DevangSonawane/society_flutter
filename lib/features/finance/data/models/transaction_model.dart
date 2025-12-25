import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

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
      ];

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: _transactionTypeFromString(json['type'] as String),
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['transaction_date'] as String? ?? json['created_at'] as String? ?? json['createdAt'] as String),
      referenceNumber: json['reference_number'] as String? ?? json['referenceNumber'] as String?,
      paidBy: json['paid_by'] as String? ?? json['paidBy'] as String?,
      paidTo: json['paid_to'] as String? ?? json['paidTo'] as String?,
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
    };
  }
}

