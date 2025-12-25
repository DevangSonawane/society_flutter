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
import '../../data/models/complaint_model.dart';
import '../../providers/complaints_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddComplaintScreen extends ConsumerStatefulWidget {
  const AddComplaintScreen({super.key});

  @override
  ConsumerState<AddComplaintScreen> createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends ConsumerState<AddComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _complainerNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _flatNumberController = TextEditingController();
  final _wingController = TextEditingController();
  final _complaintTextController = TextEditingController();
  
  String? _selectedStatus = 'Pending';
  DateTime _complaintDate = DateTime.now();
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _complainerNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _flatNumberController.dispose();
    _wingController.dispose();
    _complaintTextController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _complaintDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _complaintDate) {
      setState(() {
        _complaintDate = picked;
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

    final complaint = ComplaintModel(
      id: _uuid.v4(),
      complainerName: _complainerNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim().isNotEmpty
          ? _phoneNumberController.text.trim()
          : null,
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      flatNumber: _flatNumberController.text.trim(),
      wing: _wingController.text.trim().isNotEmpty
          ? _wingController.text.trim()
          : null,
      complaintText: _complaintTextController.text.trim(),
      status: _selectedStatus,
      complaintDate: _complaintDate,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(complaintsNotifierProvider.notifier).createComplaint(complaint);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Complaint added successfully'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding complaint: ${e.toString()}'),
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
          'Add Complaint',
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
              // Back Button
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
              
              // Complaint Information Section
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
                            Text(
                              'Complaint Information',
                              style: AppTextStyles.h3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          label: "Complainer Name *",
                          controller: _complainerNameController,
                          validator: (value) => Validators.required(value, fieldName: "Complainer Name"),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Phone Number',
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              return Validators.phone(value);
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Email Address',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              return Validators.email(value);
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Flat Number *',
                                controller: _flatNumberController,
                                validator: (value) => Validators.required(value, fieldName: 'Flat Number'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                label: 'Wing',
                                controller: _wingController,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Complaint Date
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                              label: 'Complaint Date *',
                              controller: TextEditingController(
                                text: DateFormat('dd/MM/yyyy').format(_complaintDate),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today, color: AppColors.textTertiary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Status Dropdown
                        // ignore: deprecated_member_use
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: ['Pending', 'In Progress', 'Resolved', 'Closed'].map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value;
                            });
                            HapticHelper.selection();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Complaint Text
                        CustomTextField(
                          label: 'Complaint Description *',
                          controller: _complaintTextController,
                          maxLines: 5,
                          validator: (value) => Validators.required(value, fieldName: 'Complaint Description'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
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
                        text: 'Add Complaint',
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

