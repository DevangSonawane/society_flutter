import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/finance_provider.dart';
import '../../data/models/billing_history_model.dart';
import '../../providers/billing_history_provider.dart';
import '../../../vendors/providers/vendors_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class MakePaymentScreen extends ConsumerStatefulWidget {
  const MakePaymentScreen({super.key});

  @override
  ConsumerState<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends ConsumerState<MakePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();
  final _referenceController = TextEditingController();
  final _paymentModeController = TextEditingController();
  final _paymentDetailsController = TextEditingController();
  
  String _selectedType = 'Debit';
  String _paymentCategory = 'Manual'; // 'Manual' or 'Vendor'
  String? _selectedVendorId;
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _recipientController.dispose();
    _referenceController.dispose();
    _paymentModeController.dispose();
    _paymentDetailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _paymentDate) {
      setState(() {
        _paymentDate = picked;
      });
      HapticHelper.selection();
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_paymentCategory == 'Vendor' && _selectedVendorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a vendor'),
          backgroundColor: AppColors.warningYellow,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    try {
      if (_paymentCategory == 'Vendor') {
        // Record vendor payment to billing_history
        final payment = BillingHistoryModel(
          id: _uuid.v4(),
          vendorId: _selectedVendorId,
          invoiceId: null, // Can be linked later if needed
          amountPaid: amount,
          paymentDate: _paymentDate,
          paymentMode: _paymentModeController.text.trim().isNotEmpty
              ? _paymentModeController.text.trim()
              : null,
          paymentDetails: _paymentDetailsController.text.trim().isNotEmpty
              ? _paymentDetailsController.text.trim()
              : _descriptionController.text.trim(),
          paymentTimestamp: DateTime.now(),
          createdAt: DateTime.now(),
        );

        await ref.read(billingHistoryNotifierProvider.notifier).recordPayment(payment);
        
        // Refresh vendors to show updated balances
        ref.invalidate(vendorsNotifierProvider);
      } else {
        // Create manual transaction
        final transaction = TransactionModel(
          id: _uuid.v4(),
          description: _descriptionController.text.trim(),
          amount: amount,
          type: _selectedType == 'Credit' ? TransactionType.credit : TransactionType.debit,
          createdAt: _paymentDate,
          referenceNumber: _referenceController.text.trim().isNotEmpty
              ? _referenceController.text.trim()
              : null,
          paidBy: _selectedType == 'Debit' && _recipientController.text.trim().isNotEmpty
              ? _recipientController.text.trim()
              : null,
          paidTo: _selectedType == 'Credit' && _recipientController.text.trim().isNotEmpty
              ? _recipientController.text.trim()
              : null,
          source: TransactionSource.manual,
          sourceId: _uuid.v4(),
        );

        ref.read(manualTransactionsProvider.notifier).addTransaction(transaction);
      }
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_paymentCategory == 'Vendor' 
              ? 'Vendor payment recorded successfully'
              : 'Payment recorded successfully'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording payment: ${e.toString()}'),
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
          'Make Payment',
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
                  text: 'Back to Finance',
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
                              Icons.payment,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Payment Information',
                              style: AppTextStyles.h3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        DropdownButtonFormField<String>(
                          value: _paymentCategory,
                          decoration: InputDecoration(
                            labelText: 'Payment Category *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: ['Manual', 'Vendor'].map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _paymentCategory = value!;
                              if (value == 'Manual') {
                                _selectedVendorId = null;
                              }
                            });
                            HapticHelper.selection();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        if (_paymentCategory == 'Vendor') ...[
                          Consumer(
                            builder: (context, ref, child) {
                              final vendorsAsync = ref.watch(vendorsProvider);
                              return vendorsAsync.when(
                                data: (vendors) {
                                  return DropdownButtonFormField<String>(
                                    value: _selectedVendorId,
                                    decoration: InputDecoration(
                                      labelText: 'Select Vendor *',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: AppColors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    items: vendors.map((vendor) {
                                      return DropdownMenuItem(
                                        value: vendor.id,
                                        child: Text(vendor.vendorName),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedVendorId = value;
                                      });
                                      HapticHelper.selection();
                                    },
                                    validator: (value) {
                                      if (_paymentCategory == 'Vendor' && (value == null || value.isEmpty)) {
                                        return 'Please select a vendor';
                                      }
                                      return null;
                                    },
                                  );
                                },
                                loading: () => const CircularProgressIndicator(),
                                error: (error, stack) => Text('Error loading vendors: $error'),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ] else ...[
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: InputDecoration(
                              labelText: 'Transaction Type *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: ['Credit', 'Debit'].map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                              HapticHelper.selection();
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        CustomTextField(
                          label: 'Description *',
                          controller: _descriptionController,
                          validator: (value) => Validators.required(value, fieldName: 'Description'),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Amount (₹) *',
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
                        
                        if (_paymentCategory == 'Manual') ...[
                          CustomTextField(
                            label: 'Recipient/Payer',
                            controller: _recipientController,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Reference Number',
                            controller: _referenceController,
                          ),
                        ] else ...[
                          CustomTextField(
                            label: 'Payment Mode',
                            controller: _paymentModeController,
                            hint: 'e.g., UPI, Cash, Bank Transfer',
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Payment Details',
                            controller: _paymentDetailsController,
                            hint: 'Transaction ID, cheque number, etc.',
                            maxLines: 2,
                          ),
                        ],
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                              label: 'Payment Date *',
                              controller: TextEditingController(
                                text: DateFormat('dd/MM/yyyy').format(_paymentDate),
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
                child: Responsive.isMobile(context)
                    ? Column(
                        children: [
                          CustomButton(
                            text: 'Record Payment',
                            icon: Icons.payment,
                            onPressed: _submitForm,
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: 12),
                          CustomButton(
                            text: 'Cancel',
                            onPressed: () => Navigator.pop(context),
                            type: ButtonType.secondary,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Cancel',
                              onPressed: () => Navigator.pop(context),
                              type: ButtonType.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Record Payment',
                              icon: Icons.payment,
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

