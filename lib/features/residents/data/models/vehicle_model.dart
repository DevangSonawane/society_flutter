import 'package:equatable/equatable.dart';

class VehicleModel extends Equatable {
  final String vehicleNumber;
  final String vehicleType;

  const VehicleModel({
    required this.vehicleNumber,
    required this.vehicleType,
  });

  @override
  List<Object?> get props => [vehicleNumber, vehicleType];

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Handle vehicle number from either snake_case or camelCase
    final vehicleNumber = json['vehicle_number'] as String? ?? 
                         json['vehicleNumber'] as String? ?? 
                         '';
    
    // Handle vehicle type from either snake_case or camelCase
    final vehicleType = json['vehicle_type'] as String? ?? 
                       json['vehicleType'] as String? ?? 
                       'car';
    
    return VehicleModel(
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
    };
  }
}

