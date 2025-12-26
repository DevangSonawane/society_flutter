import 'package:equatable/equatable.dart';

class ComplaintModel extends Equatable {
  final String id;
  final String complainerName;
  final String? phoneNumber;
  final String? email;
  final String? flatNumber;
  final String? wing;
  final String complaintText;
  final String? status;
  final DateTime complaintDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ComplaintModel({
    required this.id,
    required this.complainerName,
    this.phoneNumber,
    this.email,
    this.flatNumber,
    this.wing,
    required this.complaintText,
    this.status,
    required this.complaintDate,
    required this.createdAt,
    this.updatedAt,
  });

  // Convenience getters for backward compatibility
  String get name => complainerName;
  String? get phone => phoneNumber;

  @override
  List<Object?> get props => [
        id,
        complainerName,
        phoneNumber,
        email,
        flatNumber,
        wing,
        complaintText,
        status,
        complaintDate,
        createdAt,
        updatedAt,
      ];

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as String,
      complainerName: json['complainer_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      flatNumber: json['flat_number'] as String,
      wing: json['wing'] as String?,
      complaintText: json['complaint_text'] as String,
      status: json['status'] as String? ?? 'Pending',
      complaintDate: json['complaint_date'] != null
          ? DateTime.parse(json['complaint_date'] as String)
          : DateTime.now(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complainer_name': complainerName,
      'phone_number': phoneNumber,
      'email': email,
      'flat_number': flatNumber,
      'wing': wing,
      'complaint_text': complaintText,
      'status': status,
      'complaint_date': complaintDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

