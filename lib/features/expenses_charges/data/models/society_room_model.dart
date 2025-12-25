import 'package:equatable/equatable.dart';

enum RoomStatus { available, occupied, maintenance }
enum RoomType { commercialOffice, shop }

class SocietyRoomModel extends Equatable {
  final String id;
  final String roomNumber;
  final RoomType roomType;
  final RoomStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? shopOwnerName;
  final String? shopOwnerPhone;
  final String? shopOwnerEmail;
  final String? shopOfficeName;
  final String? officeTelephone;
  final int? workersEmployees;
  final String? managerName;
  final String? managerPhone;
  final int? financeMonth;
  final double? financeMoney;

  const SocietyRoomModel({
    required this.id,
    required this.roomNumber,
    required this.roomType,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.shopOwnerName,
    this.shopOwnerPhone,
    this.shopOwnerEmail,
    this.shopOfficeName,
    this.officeTelephone,
    this.workersEmployees,
    this.managerName,
    this.managerPhone,
    this.financeMonth,
    this.financeMoney,
  });

  @override
  List<Object?> get props => [
        id,
        roomNumber,
        roomType,
        status,
        notes,
        createdAt,
        updatedAt,
        shopOwnerName,
        shopOwnerPhone,
        shopOwnerEmail,
        shopOfficeName,
        officeTelephone,
        workersEmployees,
        managerName,
        managerPhone,
        financeMonth,
        financeMoney,
      ];

  factory SocietyRoomModel.fromJson(Map<String, dynamic> json) {
    return SocietyRoomModel(
      id: json['id'] as String,
      roomNumber: json['room_number'] as String,
      roomType: _roomTypeFromString(json['room_type'] as String),
      status: _roomStatusFromString(json['status'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      shopOwnerName: json['shop_owner_name'] as String?,
      shopOwnerPhone: json['shop_owner_phone'] as String?,
      shopOwnerEmail: json['shop_owner_email'] as String?,
      shopOfficeName: json['shop_office_name'] as String?,
      officeTelephone: json['office_telephone'] as String?,
      workersEmployees: json['workers_employees'] as int?,
      managerName: json['manager_name'] as String?,
      managerPhone: json['manager_phone'] as String?,
      financeMonth: json['finance_month'] as int?,
      financeMoney: json['finance_money'] != null
          ? (json['finance_money'] as num).toDouble()
          : null,
    );
  }

  static RoomType _roomTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'commercial-office':
        return RoomType.commercialOffice;
      case 'shop':
        return RoomType.shop;
      default:
        return RoomType.commercialOffice;
    }
  }

  static RoomStatus _roomStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'occupied':
        return RoomStatus.occupied;
      case 'maintenance':
        return RoomStatus.maintenance;
      case 'available':
      default:
        return RoomStatus.available;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_number': roomNumber,
      'room_type': roomType == RoomType.commercialOffice ? 'commercial-office' : 'shop',
      'status': status.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'shop_owner_name': shopOwnerName,
      'shop_owner_phone': shopOwnerPhone,
      'shop_owner_email': shopOwnerEmail,
      'shop_office_name': shopOfficeName,
      'office_telephone': officeTelephone,
      'workers_employees': workersEmployees,
      'manager_name': managerName,
      'manager_phone': managerPhone,
      'finance_month': financeMonth,
      'finance_money': financeMoney,
    };
  }
}

