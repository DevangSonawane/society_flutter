import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/models/deposit_model.dart';
import '../../providers/deposits_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddDepositScreen extends ConsumerStatefulWidget {
  const AddDepositScreen({super.key});

  @override
  ConsumerState<AddDepositScreen> createState() => _AddDepositScreenState();
}

class _AddDepositScreenState extends ConsumerState<AddDepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _flatNumberController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  DepositStatus _selectedStatus = DepositStatus.pending;
  DateTime _depositDate = DateTime.now();
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _flatNumberController.dispose();
    _ownerNameController.dispose();
    _phoneNumberController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _depositDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _depositDate) {
      setState(() {
        _depositDate = picked;
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

    final deposit = DepositModel(
      id: _uuid.v4(),
      flatNumber: _flatNumberController.text.trim(),
      residentName: _ownerNameController.text.trim().isNotEmpty
          ? _ownerNameController.text.trim()
          : '',
      ownerName: _ownerNameController.text.trim().isNotEmpty
          ? _ownerNameController.text.trim()
          : null,
      phoneNumber: _phoneNumberController.text.trim().isNotEmpty
          ? _phoneNumberController.text.trim()
          : null,
      amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
      depositDate: _depositDate,
      status: _selectedStatus,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(depositsNotifierProvider.notifier).createDeposit(deposit);
      
      if (!mounted) return;

      CustomSnackbar.show(
        context,
        message: 'Deposit added successfully',
        type: SnackbarType.success,
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      CustomSnackbar.show(
        context,
        message: 'Error adding deposit: ${e.toString()}',
        type: SnackbarType.error,
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final padding = isMobile ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add Deposit', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideWidget(
                delay: const Duration(milliseconds: 100),
                child: CustomButton(
                  text: 'Back to Deposits',
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
                    borderRadius: BorderRadius.circular(16),
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
                              Icons.account_balance_wallet,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text('Deposit Information', style: AppTextStyles.h3),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          label: 'Flat Number *',
                          controller: _flatNumberController,
                          hint: 'Enter flat number',
                          validator: (value) => Validators.required(value, fieldName: 'Flat Number'),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Owner Name',
                          controller: _ownerNameController,
                          hint: 'Enter owner name',
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Phone Number',
                          controller: _phoneNumberController,
                          hint: 'Enter phone number',
                          keyboardType: TextInputType.phone,
                          validator: (value) => value?.isEmpty ?? true ? null : Validators.phone(value),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Amount *',
                          controller: _amountController,
                          hint: 'Enter deposit amount',
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
                              label: 'Deposit Date *',
                              controller: TextEditingController(
                                text: DateFormat('yyyy-MM-dd').format(_depositDate),
                              ),
                              hint: 'Select date',
                              suffixIcon: const Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<DepositStatus>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status *',
                            border: OutlineInputBorder(),
                          ),
                          items: DepositStatus.values.map((status) {
                            String label;
                            switch (status) {
                              case DepositStatus.pending:
                                label = 'Pending';
                                break;
                              case DepositStatus.refunded:
                                label = 'Refunded';
                                break;
                              case DepositStatus.forfeited:
                                label = 'Forfeited';
                                break;
                            }
                            return DropdownMenuItem(
                              value: status,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                            HapticHelper.selection();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Notes',
                          controller: _notesController,
                          hint: 'Additional notes (optional)',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              FadeSlideWidget(
                delay: const Duration(milliseconds: 500),
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
                        text: 'Add Deposit',
                        icon: Icons.check,
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

