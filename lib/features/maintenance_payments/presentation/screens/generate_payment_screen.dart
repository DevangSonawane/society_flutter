import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../providers/maintenance_payments_provider.dart';
import '../../../../features/residents/providers/residents_provider.dart';
import 'package:intl/intl.dart';

class GeneratePaymentScreen extends ConsumerStatefulWidget {
  const GeneratePaymentScreen({super.key});

  @override
  ConsumerState<GeneratePaymentScreen> createState() => _GeneratePaymentScreenState();
}

class _GeneratePaymentScreenState extends ConsumerState<GeneratePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '2000');
  int? _selectedMonth;
  int? _selectedYear;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _generatePayments() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMonth == null || _selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select month and year'),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final residentsAsync = ref.read(residentsProvider);
      final residents = residentsAsync.value ?? [];
      
      final residentsData = residents.map((r) => {
        'id': r.id,
        'ownerName': r.ownerName,
        'flatNumber': r.flatNumber,
      }).toList();

      final amount = double.tryParse(_amountController.text.trim()) ?? 2000.0;
      
      await ref.read(maintenancePaymentsNotifierProvider.notifier).generatePaymentsForMonth(
        month: _selectedMonth!,
        year: _selectedYear!,
        amount: amount,
        residents: residentsData,
      );
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Generated ${residents.length} payment invoices for ${DateFormat('MMMM yyyy').format(DateTime(_selectedYear!, _selectedMonth!))}'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating payments: ${e.toString()}'),
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
    final now = DateTime.now();
    final currentYear = now.year;
    
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
          'Generate Payments',
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
                  text: 'Back to Maintenance Payments',
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
                              'Payment Generation',
                              style: AppTextStyles.h3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedMonth,
                                decoration: InputDecoration(
                                  labelText: 'Month *',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                items: List.generate(12, (index) {
                                  final month = index + 1;
                                  return DropdownMenuItem(
                                    value: month,
                                    child: Text(DateFormat('MMMM').format(DateTime(2000, month))),
                                  );
                                }),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMonth = value;
                                  });
                                  HapticHelper.selection();
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _selectedYear,
                                decoration: InputDecoration(
                                  labelText: 'Year *',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                items: List.generate(5, (index) {
                                  final year = currentYear - 2 + index;
                                  return DropdownMenuItem(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedYear = value;
                                  });
                                  HapticHelper.selection();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Amount per Resident (₹) *',
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
                        text: 'Generate Payments',
                        icon: Icons.payment,
                        onPressed: _generatePayments,
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

