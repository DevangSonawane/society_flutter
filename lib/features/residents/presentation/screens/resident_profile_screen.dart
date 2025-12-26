import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/formatters.dart';
import '../../providers/residents_provider.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../data/models/resident_model.dart';

class ResidentProfileScreen extends ConsumerWidget {
  const ResidentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final padding = Responsive.getScreenPadding(context);

    if (user == null || user.flatNo == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: AppColors.white,
        ),
        body: Center(
          child: Text(
            'Profile information not available. Please contact administrator.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final residentAsync = ref.watch(residentsProvider);
    
    return residentAsync.when(
      data: (residents) {
        // Find resident by flat number
        ResidentModel? resident;
        try {
          resident = residents.firstWhere(
            (r) => r.flatNumber == user.flatNo,
          );
        } catch (e) {
          // Resident not found
        }

        if (resident == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(
              title: const Text('My Profile'),
              backgroundColor: AppColors.white,
            ),
            body: Center(
              child: Padding(
                padding: padding,
                child: Text(
                  'Resident data not found for flat ${user.flatNo}. Please contact administrator.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            title: const Text('My Profile'),
            backgroundColor: AppColors.white,
          ),
          body: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flat Information Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Flat Information', style: AppTextStyles.h3),
                        const SizedBox(height: 16),
                        _buildInfoRow('Flat Number', resident.flatNumber),
                        _buildInfoRow('Residency Type', resident.typeString),
                        _buildInfoRow('Owner Name', resident.ownerName),
                        _buildInfoRow('Phone', resident.phoneNumber),
                        if (resident.email != null)
                          _buildInfoRow('Email', resident.email!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Residents Living Card
                if (resident.residentsLiving.isNotEmpty) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Residents Living', style: AppTextStyles.h3),
                          const SizedBox(height: 16),
                          ...resident.residentsLiving.map((member) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          member.name,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          member.phoneNumber,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (member.dateJoined != null)
                                    Text(
                                      'Joined: ${member.dateJoined}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Vehicle Details Card
                if (resident.vehicleDetail.isNotEmpty) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vehicle Details', style: AppTextStyles.h3),
                          const SizedBox(height: 16),
                          ...resident.vehicleDetail.map((vehicle) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    size: 20,
                                    color: AppColors.primaryPurple,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${vehicle.vehicleType}: ${vehicle.vehicleNumber}',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Rental Information (if rented)
                if (resident.residencyType == ResidentType.rented) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rental Information', style: AppTextStyles.h3),
                          const SizedBox(height: 16),
                          if (resident.currentRenterName != null)
                            _buildInfoRow('Current Renter', resident.currentRenterName!),
                          if (resident.currentRenterPhone != null)
                            _buildInfoRow('Renter Phone', resident.currentRenterPhone!),
                          if (resident.monthlyRent != null)
                            _buildInfoRow('Monthly Rent', AppFormatters.currency(resident.monthlyRent!)),
                          if (resident.rentStartDate != null)
                            _buildInfoRow('Rent Start Date', AppFormatters.dateShort(resident.rentStartDate!)),
                          if (resident.rentEndDate != null)
                            _buildInfoRow('Rent End Date', AppFormatters.dateShort(resident.rentEndDate!)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: AppColors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: AppColors.white,
        ),
        body: Center(
          child: Padding(
            padding: padding,
            child: Text(
              'Error loading profile: $error',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.errorRed,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

