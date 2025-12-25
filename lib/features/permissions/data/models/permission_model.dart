import 'package:equatable/equatable.dart';

class PermissionModel extends Equatable {
  final String id;
  final String residentName;
  final String? phoneNumber;
  final String? email;
  final String flatNumber;
  final String? wing;
  final String permissionText;
  final String? status;
  final DateTime permissionDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PermissionModel({
    required this.id,
    required this.residentName,
    this.phoneNumber,
    this.email,
    required this.flatNumber,
    this.wing,
    required this.permissionText,
    this.status,
    required this.permissionDate,
    required this.createdAt,
    this.updatedAt,
  });

  // Convenience getters for backward compatibility
  String get name => residentName;
  String? get phone => phoneNumber;

  @override
  List<Object?> get props => [
        id,
        residentName,
        phoneNumber,
        email,
        flatNumber,
        wing,
        permissionText,
        status,
        permissionDate,
        createdAt,
        updatedAt,
      ];

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as String,
      residentName: json['resident_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      flatNumber: json['flat_number'] as String,
      wing: json['wing'] as String?,
      permissionText: json['permission_text'] as String,
      status: json['status'] as String? ?? 'Pending',
      permissionDate: json['permission_date'] != null
          ? DateTime.parse(json['permission_date'] as String)
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
      'resident_name': residentName,
      'phone_number': phoneNumber,
      'email': email,
      'flat_number': flatNumber,
      'wing': wing,
      'permission_text': permissionText,
      'status': status,
      'permission_date': permissionDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

