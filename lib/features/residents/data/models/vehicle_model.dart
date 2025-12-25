import 'package:equatable/equatable.dart';

class VehicleModel extends Equatable {
  final String id;
  final String vehicleNumber;
  final String vehicleType;

  const VehicleModel({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleType,
  });

  @override
  List<Object?> get props => [id, vehicleNumber, vehicleType];

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Generate ID if not present (for backward compatibility)
    final id = json['id'] as String? ?? 
               '${json['vehicle_number'] ?? json['vehicleNumber'] ?? ''}_${json['vehicle_type'] ?? json['vehicleType'] ?? ''}';
    
    // Handle vehicle number from either snake_case or camelCase
    final vehicleNumber = json['vehicle_number'] as String? ?? 
                         json['vehicleNumber'] as String? ?? 
                         '';
    
    // Handle vehicle type from either snake_case or camelCase
    final vehicleType = json['vehicle_type'] as String? ?? 
                       json['vehicleType'] as String? ?? 
                       'Car';
    
    return VehicleModel(
      id: id,
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
    };
  }
}

