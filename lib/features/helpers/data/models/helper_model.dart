import 'package:equatable/equatable.dart';

class HelperModel extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final String? helperType; // 'Home', 'Society'
  final String? gender; // 'Male', 'Female'
  final List<String> rooms; // Array of room assignments
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? helperWork;
  final String? photoUrl;
  final Map<String, dynamic>? flatDetails; // JSONB
  final String? wing;
  final String? secretary;

  const HelperModel({
    required this.id,
    required this.name,
    this.phone,
    this.helperType,
    this.gender,
    this.rooms = const [],
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.helperWork,
    this.photoUrl,
    this.flatDetails,
    this.wing,
    this.secretary,
  });
  
  // Convenience getters for backward compatibility
  String? get phoneNumber => phone;
  String? get type => helperType;
  
  List<String> get assignedFlats {
    if (flatDetails != null && flatDetails is List) {
      return (flatDetails as List).map((e) => e.toString()).toList();
    }
    return rooms;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        helperType,
        gender,
        rooms,
        notes,
        createdAt,
        updatedAt,
        helperWork,
        photoUrl,
        flatDetails,
        wing,
        secretary,
      ];

  factory HelperModel.fromJson(Map<String, dynamic> json) {
    return HelperModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      helperType: json['helper_type'] as String?,
      gender: json['gender'] as String?,
      rooms: json['rooms'] != null
          ? List<String>.from(json['rooms'] as List)
          : [],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      helperWork: json['helper_work'] as String?,
      photoUrl: json['photo_url'] as String?,
      flatDetails: json['flat_details'] as Map<String, dynamic>?,
      wing: json['wing'] as String?,
      secretary: json['secretary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'helper_type': helperType,
      'gender': gender,
      'rooms': rooms,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'helper_work': helperWork,
      'photo_url': photoUrl,
      'flat_details': flatDetails,
      'wing': wing,
      'secretary': secretary,
    };
  }
}

