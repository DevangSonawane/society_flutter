import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/resident_model.dart';
import 'edit_resident_screen.dart';

class ViewResidentScreen extends StatelessWidget {
  final ResidentModel resident;

  const ViewResidentScreen({
    super.key,
    required this.resident,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Resident Details',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryPurple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditResidentScreen(resident: resident),
                ),
              );
            },
            tooltip: 'Edit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeSlideWidget(
              delay: const Duration(milliseconds: 100),
              child: CustomButton(
                text: 'Back to Residents',
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
                type: ButtonType.secondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Basic Information
            FadeSlideWidget(
              delay: const Duration(milliseconds: 200),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: AppColors.primaryPurple,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text('Basic Information', style: AppTextStyles.h3),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow('Owner Name', resident.ownerName),
                      const SizedBox(height: 16),
                      _buildInfoRow('Flat Number', resident.flatNumber),
                      const SizedBox(height: 16),
                      _buildInfoRow('Residency Type', resident.typeString),
                      const SizedBox(height: 16),
                      _buildInfoRow('Phone Number', resident.phoneNumber),
                      if (resident.email != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow('Email', resident.email!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Residents Living
            if (resident.residentsLiving.isNotEmpty)
              FadeSlideWidget(
                delay: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Residents Living', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...resident.residentsLiving.map((member) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(member.name, style: AppTextStyles.bodyMedium),
                                      Text(member.phoneNumber, style: AppTextStyles.bodySmall),
                                    ],
                                  ),
                                ),
                                Text(
                                  member.dateJoined != null 
                                    ? AppFormatters.dateShort(member.dateJoined!)
                                    : 'N/A',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            if (resident.residentsLiving.isNotEmpty) const SizedBox(height: 24),
            
            // Vehicles
            if (resident.vehicleDetail.isNotEmpty)
              FadeSlideWidget(
                delay: const Duration(milliseconds: 400),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Vehicles', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...resident.vehicleDetail.map((vehicle) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(vehicle.vehicleNumber, style: AppTextStyles.bodyMedium),
                                ),
                                Text(
                                  vehicle.vehicleType,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            if (resident.vehicleDetail.isNotEmpty) const SizedBox(height: 24),
            
            // Actions
            FadeSlideWidget(
              delay: const Duration(milliseconds: 500),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Edit Resident',
                      icon: Icons.edit,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditResidentScreen(resident: resident),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: AppTextStyles.bodySmall.copyWith(
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
    );
  }
}

