import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../data/models/vendor_model.dart';
import '../../providers/vendors_provider.dart';
import 'package:uuid/uuid.dart';

class AddVendorScreen extends ConsumerStatefulWidget {
  const AddVendorScreen({super.key});

  @override
  ConsumerState<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends ConsumerState<AddVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vendorNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _workDetailsController = TextEditingController();
  final _totalBillController = TextEditingController();
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _vendorNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _workDetailsController.dispose();
    _totalBillController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final totalBill = double.tryParse(_totalBillController.text.trim()) ?? 0.0;

    final vendor = VendorModel(
      id: _uuid.v4(),
      vendorName: _vendorNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      workDetails: _workDetailsController.text.trim().isNotEmpty
          ? _workDetailsController.text.trim()
          : null,
      totalBill: totalBill,
      paidBill: 0.0,
      outstandingBill: totalBill,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(vendorsNotifierProvider.notifier).createVendor(vendor);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vendor added successfully'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding vendor: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
          'Add Vendor',
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: _formKey,
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
                            Text(
                              'Vendor Information',
                              style: AppTextStyles.h3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          label: "Vendor Name *",
                          controller: _vendorNameController,
                          validator: (value) => Validators.required(value, fieldName: "Vendor Name"),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Email Address *',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => Validators.email(value),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Phone Number *',
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          validator: (value) => Validators.phone(value),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Work Details',
                          controller: _workDetailsController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Total Bill (₹)',
                          controller: _totalBillController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final amount = double.tryParse(value);
                              if (amount == null || amount < 0) {
                                return 'Please enter a valid amount';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              FadeSlideWidget(
                delay: const Duration(milliseconds: 300),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        type: ButtonType.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Add Vendor',
                        icon: Icons.add,
                        onPressed: _submitForm,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

