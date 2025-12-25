import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String userId;
  final String userName;
  final String email;
  final String? mobileNumber;
  final String passwordHash;
  final String role;
  final String? flatNo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.userId,
    required this.userName,
    required this.email,
    this.mobileNumber,
    required this.passwordHash,
    required this.role,
    this.flatNo,
    required this.createdAt,
    this.updatedAt,
  });
  
  // Convenience getters for backward compatibility
  String get id => userId;
  String get name => userName;
  String? get phone => mobileNumber;
  String? get flatNumber => flatNo;

  @override
  List<Object?> get props => [userId, userName, email, mobileNumber, passwordHash, role, flatNo, createdAt, updatedAt];

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      email: json['email'] as String,
      mobileNumber: json['mobile_number'] as String?,
      passwordHash: json['password_hash'] as String? ?? '',
      role: json['role'] as String,
      flatNo: json['flat_no'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'email': email,
      'mobile_number': mobileNumber,
      'password_hash': passwordHash,
      'role': role,
      'flat_no': flatNo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

