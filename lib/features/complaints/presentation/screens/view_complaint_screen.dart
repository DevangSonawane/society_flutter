import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/complaint_model.dart';
import 'edit_complaint_screen.dart';

class ViewComplaintScreen extends StatelessWidget {
  final ComplaintModel complaint;

  const ViewComplaintScreen({
    super.key,
    required this.complaint,
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
          'Complaint Details',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryPurple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditComplaintScreen(complaint: complaint),
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
                text: 'Back to Complaints',
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
                            Icons.report_problem,
                            color: AppColors.primaryPurple,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text('Complaint Information', style: AppTextStyles.h3),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow('Complainer Name', complaint.complainerName),
                      if (complaint.phoneNumber != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow('Phone Number', complaint.phoneNumber!),
                      ],
                      if (complaint.email != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow('Email', complaint.email!),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoRow('Flat Number', complaint.flatNumber ?? 'N/A'),
                          ),
                          if (complaint.wing != null)
                            Expanded(
                              child: _buildInfoRow('Wing', complaint.wing!),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Complaint Date', AppFormatters.dateShort(complaint.complaintDate)),
                      const SizedBox(height: 16),
                      _buildInfoRow('Status', complaint.status ?? 'Pending'),
                      const SizedBox(height: 16),
                      _buildInfoRow('Complaint Description', complaint.complaintText, isMultiline: true),
                      const SizedBox(height: 16),
                      _buildInfoRow('Created Date', AppFormatters.dateShort(complaint.createdAt)),
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
                      text: 'Edit Complaint',
                      icon: Icons.edit,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditComplaintScreen(complaint: complaint),
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

