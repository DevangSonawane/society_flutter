import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/vendor_model.dart';
import 'edit_vendor_screen.dart';

class ViewVendorScreen extends StatelessWidget {
  final VendorModel vendor;

  const ViewVendorScreen({
    super.key,
    required this.vendor,
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
          'Vendor Details',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primaryPurple),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditVendorScreen(vendor: vendor),
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
                text: 'Back to Vendors',
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
                            Icons.business,
                            color: AppColors.primaryPurple,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text('Vendor Information', style: AppTextStyles.h3),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildInfoRow('Vendor Name', vendor.vendorName),
                      const SizedBox(height: 16),
                      _buildInfoRow('Email', vendor.email),
                      const SizedBox(height: 16),
                      _buildInfoRow('Phone Number', vendor.phoneNumber),
                      if (vendor.workDetails != null) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow('Work Details', vendor.workDetails!, isMultiline: true),
                      ],
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      _buildInfoRow('Total Bill', AppFormatters.currency(vendor.totalBill)),
                      const SizedBox(height: 16),
                      _buildInfoRow('Paid Amount', AppFormatters.currency(vendor.paidBill)),
                      const SizedBox(height: 16),
                      _buildInfoRow('Outstanding', AppFormatters.currency(vendor.outstandingBill)),
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
                      text: 'Edit Vendor',
                      icon: Icons.edit,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditVendorScreen(vendor: vendor),
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

