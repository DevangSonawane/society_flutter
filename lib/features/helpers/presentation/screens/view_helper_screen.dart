import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/helper_model.dart';
import 'edit_helper_screen.dart';

class ViewHelperScreen extends StatelessWidget {
  final HelperModel helper;

  const ViewHelperScreen({
    super.key,
    required this.helper,
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
          'Helper Details',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryPurple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHelperScreen(helper: helper),
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
                text: 'Back to Helpers',
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
                          Text('Helper Information', style: AppTextStyles.h3),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow('Name', helper.name),
                      if (helper.phone != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow('Phone Number', helper.phone!),
                      ],
                      if (helper.helperType != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow('Type', helper.helperType!),
                      ],
                      if (helper.gender != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow('Gender', helper.gender!),
                      ],
                      if (helper.assignedFlats.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow('Assigned Flats', helper.assignedFlats.join(', '), isMultiline: true),
                      ],
                      if (helper.notes != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow('Notes', helper.notes!, isMultiline: true),
                      ],
                      const SizedBox(height: 16),
                      _buildInfoRow('Created Date', AppFormatters.dateShort(helper.createdAt)),
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
                      text: 'Edit Helper',
                      icon: Icons.edit,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditHelperScreen(helper: helper),
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

  Widget _buildInfoRow(String label, String value, {bool isMultiline = false}) {
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
          maxLines: isMultiline ? null : 1,
          overflow: isMultiline ? null : TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

