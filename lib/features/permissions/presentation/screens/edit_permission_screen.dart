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
import 'package:intl/intl.dart';

class EditPermissionScreen extends ConsumerStatefulWidget {
  final PermissionModel permission;

  const EditPermissionScreen({
    super.key,
    required this.permission,
  });

  @override
  ConsumerState<EditPermissionScreen> createState() => _EditPermissionScreenState();
}

class _EditPermissionScreenState extends ConsumerState<EditPermissionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _residentNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _flatNumberController;
  late TextEditingController _wingController;
  late TextEditingController _permissionTextController;
  
  late String? _selectedStatus;
  late DateTime _permissionDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _residentNameController = TextEditingController(text: widget.permission.residentName);
    _phoneNumberController = TextEditingController(text: widget.permission.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.permission.email ?? '');
    _flatNumberController = TextEditingController(text: widget.permission.flatNumber);
    _wingController = TextEditingController(text: widget.permission.wing ?? '');
    _permissionTextController = TextEditingController(text: widget.permission.permissionText);
    _selectedStatus = widget.permission.status ?? 'Pending';
    _permissionDate = widget.permission.permissionDate;
  }

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

    final updatedPermission = PermissionModel(
      id: widget.permission.id,
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
      createdAt: widget.permission.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(permissionsNotifierProvider.notifier).updatePermission(updatedPermission);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Permission updated successfully'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating permission: ${e.toString()}'),
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
          'Edit Permission',
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
                  text: 'Back to Permissions',
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
                        text: 'Update Permission',
                        icon: Icons.save,
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

