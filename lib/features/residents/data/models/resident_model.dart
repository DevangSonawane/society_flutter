import 'package:equatable/equatable.dart';
import 'vehicle_model.dart';

enum ResidentType { ownerLiving, rented }

class ResidentModel extends Equatable {
  final String id;
  final String ownerName;
  final String flatNumber;
  final ResidentType residencyType;
  final String phoneNumber;
  final String? email;
  final String? rentAgreementUrl;
  final String? currentRenterName;
  final String? currentRenterPhone;
  final String? currentRenterEmail;
  final String? oldRenterName;
  final String? oldRenterPhone;
  final String? oldRenterEmail;
  final DateTime? rentStartDate;
  final DateTime? rentEndDate;
  final double? monthlyRent;
  final List<ResidentMember> residentsLiving; // JSONB array
  final List<VehicleModel> vehicleDetail; // JSONB array
  final List<Map<String, dynamic>>? documents; // JSONB array
  final String? brokerName;
  final String? brokerPhone;
  final String? brokerEmail;
  final String? brokerCompany;
  final double? brokerCommission;
  final List<Map<String, dynamic>>? ownerHistory; // JSONB array
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ResidentModel({
    required this.id,
    required this.ownerName,
    required this.flatNumber,
    required this.residencyType,
    required this.phoneNumber,
    this.email,
    this.rentAgreementUrl,
    this.currentRenterName,
    this.currentRenterPhone,
    this.currentRenterEmail,
    this.oldRenterName,
    this.oldRenterPhone,
    this.oldRenterEmail,
    this.rentStartDate,
    this.rentEndDate,
    this.monthlyRent,
    this.residentsLiving = const [],
    this.vehicleDetail = const [],
    this.documents,
    this.brokerName,
    this.brokerPhone,
    this.brokerEmail,
    this.brokerCompany,
    this.brokerCommission,
    this.ownerHistory,
    required this.createdAt,
    this.updatedAt,
  });

  // Convenience getters for backward compatibility
  List<ResidentMember> get members => residentsLiving;
  List<VehicleModel> get vehicles => vehicleDetail;
  ResidentType get type => residencyType;
  String get status => 'active'; // Default status, can be extended later

  String get typeString {
    switch (residencyType) {
      case ResidentType.ownerLiving:
        return 'Owner-Living';
      case ResidentType.rented:
        return 'Rented';
    }
  }

  @override
  List<Object?> get props => [
        id,
        ownerName,
        flatNumber,
        residencyType,
        phoneNumber,
        email,
        rentAgreementUrl,
        currentRenterName,
        currentRenterPhone,
        currentRenterEmail,
        oldRenterName,
        oldRenterPhone,
        oldRenterEmail,
        rentStartDate,
        rentEndDate,
        monthlyRent,
        residentsLiving,
        vehicleDetail,
        documents,
        brokerName,
        brokerPhone,
        brokerEmail,
        brokerCompany,
        brokerCommission,
        ownerHistory,
        createdAt,
        updatedAt,
      ];

  factory ResidentModel.fromJson(Map<String, dynamic> json) {
    return ResidentModel(
      id: json['id'] as String,
      ownerName: json['owner_name'] as String,
      flatNumber: json['flat_number'] as String,
      residencyType: _residentTypeFromString(json['residency_type'] as String),
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      rentAgreementUrl: json['rent_agreement_url'] as String?,
      currentRenterName: json['current_renter_name'] as String?,
      currentRenterPhone: json['current_renter_phone'] as String?,
      currentRenterEmail: json['current_renter_email'] as String?,
      oldRenterName: json['old_renter_name'] as String?,
      oldRenterPhone: json['old_renter_phone'] as String?,
      oldRenterEmail: json['old_renter_email'] as String?,
      rentStartDate: json['rent_start_date'] != null
          ? DateTime.parse(json['rent_start_date'] as String)
          : null,
      rentEndDate: json['rent_end_date'] != null
          ? DateTime.parse(json['rent_end_date'] as String)
          : null,
      monthlyRent: json['monthly_rent'] != null
          ? (json['monthly_rent'] as num).toDouble()
          : null,
      residentsLiving: json['residents_living'] != null
          ? (json['residents_living'] as List)
              .map((m) => ResidentMember.fromJson(m as Map<String, dynamic>))
              .toList()
          : [],
      vehicleDetail: json['vehicle_detail'] != null
          ? (json['vehicle_detail'] as List)
              .map((v) => VehicleModel.fromJson(v as Map<String, dynamic>))
              .toList()
          : [],
      documents: json['documents'] != null
          ? List<Map<String, dynamic>>.from(json['documents'] as List)
          : null,
      brokerName: json['broker_name'] != null ? json['broker_name'] as String : null,
      brokerPhone: json['broker_phone'] != null ? json['broker_phone'] as String : null,
      brokerEmail: json['broker_email'] != null ? json['broker_email'] as String : null,
      brokerCompany: json['broker_company'] != null ? json['broker_company'] as String : null,
      brokerCommission: json['broker_commission'] != null
          ? (json['broker_commission'] as num).toDouble()
          : null,
      ownerHistory: json['owner_history'] != null
          ? List<Map<String, dynamic>>.from(json['owner_history'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static ResidentType _residentTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'owner-living':
        return ResidentType.ownerLiving;
      case 'rented':
        return ResidentType.rented;
      default:
        return ResidentType.ownerLiving;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_name': ownerName,
      'flat_number': flatNumber,
      'residency_type': residencyType == ResidentType.ownerLiving ? 'owner-living' : 'rented',
      'phone_number': phoneNumber,
      'email': email,
      'rent_agreement_url': rentAgreementUrl,
      'current_renter_name': currentRenterName,
      'current_renter_phone': currentRenterPhone,
      'current_renter_email': currentRenterEmail,
      'old_renter_name': oldRenterName,
      'old_renter_phone': oldRenterPhone,
      'old_renter_email': oldRenterEmail,
      'rent_start_date': rentStartDate?.toIso8601String().split('T')[0],
      'rent_end_date': rentEndDate?.toIso8601String().split('T')[0],
      'monthly_rent': monthlyRent,
      'residents_living': residentsLiving.map((m) => m.toJson()).toList(),
      'vehicle_detail': vehicleDetail.map((v) => v.toJson()).toList(),
      'documents': documents,
      'broker_name': brokerName,
      'broker_phone': brokerPhone,
      'broker_email': brokerEmail,
      'broker_company': brokerCompany,
      'broker_commission': brokerCommission,
      'owner_history': ownerHistory,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class ResidentMember extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? dateJoined; // Stored as string (YYYY-MM-DD format)
  final bool? isRenter;

  const ResidentMember({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.dateJoined,
    this.isRenter,
  });

  @override
  List<Object?> get props => [id, name, phoneNumber, email, dateJoined, isRenter];

  factory ResidentMember.fromJson(Map<String, dynamic> json) {
    // Generate ID if not present (for backward compatibility)
    final id = json['id'] as String? ?? 
               '${json['name']}_${json['phoneNumber'] ?? json['phone_number'] ?? ''}';
    
    // Handle phone number from either snake_case or camelCase
    final phoneNumber = json['phone_number'] as String? ?? 
                       json['phoneNumber'] as String? ?? 
                       '';
    
    // Handle date joined - can be string (YYYY-MM-DD) or DateTime
    String? dateJoined;
    if (json['date_joined'] != null && json['date_joined'].toString().isNotEmpty) {
      final dateValue = json['date_joined'];
      if (dateValue is String) {
        dateJoined = dateValue;
      } else if (dateValue is DateTime) {
        dateJoined = dateValue.toIso8601String().split('T')[0];
      }
    } else if (json['dateJoined'] != null && json['dateJoined'].toString().isNotEmpty) {
      final dateValue = json['dateJoined'];
      if (dateValue is String) {
        dateJoined = dateValue;
      } else if (dateValue is DateTime) {
        dateJoined = dateValue.toIso8601String().split('T')[0];
      }
    }
    
    // Handle isRenter from either snake_case or camelCase
    final isRenter = json['is_renter'] as bool? ?? 
                     json['isRenter'] as bool?;
    
    return ResidentMember(
      id: id,
      name: json['name'] as String,
      phoneNumber: phoneNumber,
      email: json['email'] as String?,
      dateJoined: dateJoined,
      isRenter: isRenter,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'dateJoined': dateJoined,
      'isRenter': isRenter,
    };
  }
}

