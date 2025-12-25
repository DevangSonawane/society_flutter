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
import 'package:intl/intl.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  final VendorModel vendor;

  const CreateInvoiceScreen({
    super.key,
    required this.vendor,
  });

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _invoiceDate = DateTime.now();
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _invoiceDate) {
      setState(() {
        _invoiceDate = picked;
      });
      HapticHelper.selection();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final invoiceAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final newTotalBill = widget.vendor.totalBill + invoiceAmount;
    final newOutstandingBill = newTotalBill - widget.vendor.paidBill;

    final updatedVendor = VendorModel(
      id: widget.vendor.id,
      vendorName: widget.vendor.vendorName,
      email: widget.vendor.email,
      phoneNumber: widget.vendor.phoneNumber,
      workDetails: widget.vendor.workDetails,
      totalBill: newTotalBill,
      paidBill: widget.vendor.paidBill,
      outstandingBill: newOutstandingBill,
      createdAt: widget.vendor.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(vendorsNotifierProvider.notifier).updateVendor(updatedVendor);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invoice created successfully'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating invoice: ${e.toString()}'),
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
          'Create Invoice',
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
                              Icons.receipt,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Invoice Information',
                              style: AppTextStyles.h3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        _buildInfoRow('Vendor Name', widget.vendor.vendorName),
                        const SizedBox(height: 16),
                        _buildInfoRow('Current Total Bill', '₹${widget.vendor.totalBill.toStringAsFixed(2)}'),
                        const SizedBox(height: 16),
                        _buildInfoRow('Outstanding', '₹${widget.vendor.outstandingBill.toStringAsFixed(2)}'),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          label: 'Invoice Description *',
                          controller: _descriptionController,
                          validator: (value) => Validators.required(value, fieldName: 'Description'),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Invoice Amount (₹) *',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Amount is required';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                              label: 'Invoice Date *',
                              controller: TextEditingController(
                                text: DateFormat('dd/MM/yyyy').format(_invoiceDate),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today, color: AppColors.textTertiary),
                            ),
                          ),
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
                        text: 'Create Invoice',
                        icon: Icons.receipt,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
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

