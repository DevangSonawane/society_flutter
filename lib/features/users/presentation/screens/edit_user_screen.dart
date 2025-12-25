import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../auth/data/models/user_model.dart';
import '../../providers/users_provider.dart';

class EditUserScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const EditUserScreen({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends ConsumerState<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileNumberController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late TextEditingController _flatNoController;
  
  late String _selectedRole;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _changePassword = false;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.user.userName);
    _emailController = TextEditingController(text: widget.user.email);
    _mobileNumberController = TextEditingController(text: widget.user.mobileNumber ?? '');
    _flatNoController = TextEditingController(text: widget.user.flatNo ?? '');
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _flatNoController.dispose();
    super.dispose();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_changePassword) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    final user = UserModel(
      userId: widget.user.userId,
      userName: _userNameController.text.trim(),
      email: _emailController.text.trim(),
      mobileNumber: _mobileNumberController.text.trim().isNotEmpty
          ? _mobileNumberController.text.trim()
          : null,
      passwordHash: _changePassword && _passwordController.text.isNotEmpty
          ? _hashPassword(_passwordController.text)
          : widget.user.passwordHash,
      role: _selectedRole,
      flatNo: _flatNoController.text.trim().isNotEmpty
          ? _flatNoController.text.trim()
          : null,
      createdAt: widget.user.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      await ref.read(usersNotifierProvider.notifier).updateUser(user);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User updated successfully'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user: ${e.toString()}'),
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
          'Edit User',
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
                  text: 'Back to Users',
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
                              Icons.person,
                              color: AppColors.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'User Information',
                              style: AppTextStyles.h3,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        CustomTextField(
                          label: "User Name *",
                          controller: _userNameController,
                          validator: (value) => Validators.required(value, fieldName: "User Name"),
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
                          label: 'Mobile Number',
                          controller: _mobileNumberController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              return Validators.phone(value);
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Role *',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: AppColors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: ['Admin', 'Receptionist', 'Resident'].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                            HapticHelper.selection();
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          label: 'Flat Number',
                          controller: _flatNoController,
                        ),
                        const SizedBox(height: 16),
                        
                        CheckboxListTile(
                          title: const Text('Change Password'),
                          value: _changePassword,
                          onChanged: (value) {
                            setState(() {
                              _changePassword = value ?? false;
                            });
                          },
                        ),
                        
                        if (_changePassword) ...[
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'New Password',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: _changePassword
                                ? (value) => Validators.password(value)
                                : null,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: AppColors.textTertiary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Confirm New Password',
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            validator: _changePassword
                                ? (value) => Validators.required(value, fieldName: 'Confirm Password')
                                : null,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                color: AppColors.textTertiary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ],
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
                        text: 'Update User',
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

