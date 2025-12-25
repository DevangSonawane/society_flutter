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
import '../../data/models/transaction_model.dart';
import '../../providers/finance_provider.dart';
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
  
  String _selectedType = 'Debit';
  DateTime _paymentDate = DateTime.now();
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _recipientController.dispose();
    _referenceController.dispose();
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

    setState(() {
      _isLoading = true;
    });

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

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
    );

    try {
      await ref.read(financeNotifierProvider.notifier).createTransaction(transaction);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Payment recorded successfully'),
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
                        
                        // ignore: deprecated_member_use
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
                        
                        CustomTextField(
                          label: 'Recipient/Payer',
                          controller: _recipientController,
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Reference Number',
                          controller: _referenceController,
                        ),
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

