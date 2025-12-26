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
    // Handle flatDetails that might be stored as a list in a map wrapper
    if (flatDetails != null) {
      // Check if it's a map with a '_list' key (converted from List in database)
      if (flatDetails!.containsKey('_list') && flatDetails!['_list'] is List) {
        return (flatDetails!['_list'] as List).map((e) => e.toString()).toList();
      }
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
      flatDetails: _parseFlatDetails(json['flat_details']),
      wing: json['wing'] as String?,
      secretary: json['secretary'] as String?,
    );
  }

  /// Parse flat_details which can be either a Map, List, or null
  static Map<String, dynamic>? _parseFlatDetails(dynamic value) {
    if (value == null) return null;
    
    // If it's already a Map, return it
    if (value is Map<String, dynamic>) {
      return value;
    }
    
    // If it's a List, convert it to a Map with indexed keys
    // This preserves the data structure while allowing the model to work
    if (value is List) {
      // For lists, we'll store it as a map with a special key
      // The assignedFlats getter will handle extracting the list
      return {'_list': value};
    }
    
    // Try to cast to Map if it's a dynamic Map
    try {
      return value as Map<String, dynamic>?;
    } catch (e) {
      // If casting fails, return null
      return null;
    }
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

