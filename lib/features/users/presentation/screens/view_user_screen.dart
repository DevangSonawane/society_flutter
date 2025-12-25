import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../../../auth/data/models/user_model.dart';
import 'edit_user_screen.dart';

class ViewUserScreen extends StatelessWidget {
  final UserModel user;

  const ViewUserScreen({
    super.key,
    required this.user,
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
          'User Details',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryPurple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditUserScreen(user: user),
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
                text: 'Back to Users',
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
                type: ButtonType.secondary,
              ),
            ),
            const SizedBox(height: 24),
            
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
                          Text('User Information', style: AppTextStyles.h3),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow('User Name', user.userName),
                      const SizedBox(height: 16),
                      _buildInfoRow('Email', user.email),
                      if (user.mobileNumber != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow('Mobile Number', user.mobileNumber!),
                      ],
                      const SizedBox(height: 16),
                      _buildInfoRow('Role', user.role),
                      if (user.flatNo != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow('Flat Number', user.flatNo!),
                      ],
                      const SizedBox(height: 16),
                      _buildInfoRow('Created Date', AppFormatters.dateShort(user.createdAt)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            FadeSlideWidget(
              delay: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Edit User',
                      icon: Icons.edit,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditUserScreen(user: user),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

