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
import '../../data/models/permission_model.dart';
import '../../providers/permissions_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddPermissionScreen extends ConsumerStatefulWidget {
  const AddPermissionScreen({super.key});

  @override
  ConsumerState<AddPermissionScreen> createState() => _AddPermissionScreenState();
}

class _AddPermissionScreenState extends ConsumerState<AddPermissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _residentNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _flatNumberController = TextEditingController();
  final _wingController = TextEditingController();
  final _permissionTextController = TextEditingController();
  
  String? _selectedStatus = 'Pending';
  DateTime _permissionDate = DateTime.now();
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _residentNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _flatNumberController.dispose();
    _wingController.dispose();
    _permissionTextController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _permissionDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _permissionDate) {
      setState(() {
        _permissionDate = picked;
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

    final permission = PermissionModel(
      id: _uuid.v4(),
      residentName: _residentNameController.text.trim(),
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
      permissionText: _permissionTextController.text.trim(),
      status: _selectedStatus,
      permissionDate: _permissionDate,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(permissionsNotifierProvider.notifier).createPermission(permission);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permission added successfully'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding permission: ${e.toString()}'),
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
          'Add Permission',
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
                  text: 'Back to Permissions',
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                  type: ButtonType.secondary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Permission Information Section
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
                              Icons.description,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Permission Information',
                              style: AppTextStyles.h3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          label: "Resident Name *",
                          controller: _residentNameController,
                          validator: (value) => Validators.required(value, fieldName: "Resident Name"),
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
                        
                        // Permission Date
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                              label: 'Permission Date *',
                              controller: TextEditingController(
                                text: DateFormat('dd/MM/yyyy').format(_permissionDate),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today, color: AppColors.textTertiary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Status Dropdown
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
                          items: ['Pending', 'Approved', 'Rejected'].map((status) {
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
                        
                        // Permission Text
                        CustomTextField(
                          label: 'Permission Description *',
                          controller: _permissionTextController,
                          maxLines: 5,
                          validator: (value) => Validators.required(value, fieldName: 'Permission Description'),
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
                        text: 'Add Permission',
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

