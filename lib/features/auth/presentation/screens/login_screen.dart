import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/animation_constants.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/animations/fade_in_widget.dart';
import '../../../../shared/widgets/animations/scale_animation_widget.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  
  late AnimationController _buttonScaleController;

  @override
  void initState() {
    super.initState();

    /// 🔹 SUPABASE CONNECTION TEST
    final user = Supabase.instance.client.auth.currentUser;
    debugPrint('Supabase current user: $user');
    
    // Button press animation controller
    _buttonScaleController = AnimationController(
      duration: AnimationConstants.fast,
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (success) {
      Navigator.of(context)
          .pushReplacementNamed(AppConstants.dashboardRoute);
    } else {
      // Check if user needs email confirmation
      final currentUser = Supabase.instance.client.auth.currentUser;
      String errorMessage = 'Invalid email/mobile or password.';
      
      if (currentUser != null && currentUser.emailConfirmedAt == null) {
        errorMessage = 'Please check your email (${currentUser.email}) and confirm your account before signing in. You may need to disable email confirmation in Supabase settings for development.';
      } else {
        errorMessage = 'Invalid email/mobile or password.\n\nIf this is your first login:\n1. The account will be created automatically\n2. You may need to disable "Confirm email" in Supabase Dashboard → Authentication → Settings\n3. Or check your email for confirmation link';
      }
      
      CustomSnackbar.show(
        context,
        message: errorMessage,
        type: SnackbarType.error,
        duration: const Duration(seconds: 6),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8FC), // Match website background
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Animated Logo
                      ScaleAnimationWidget(
                        duration: AnimationConstants.slow,
                        beginScale: 0.8,
                        curve: AnimationConstants.bounceCurve,
                        child: FadeInWidget(
                          duration: AnimationConstants.medium,
                          child: _buildLogo(),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      FadeInWidget(
                        duration: AnimationConstants.medium,
                        child: Text(
                          'Sign in to your account',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Login Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.primaryPurple.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Login',
                                style: AppTextStyles.h1.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enter your credentials to access the society management system',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Email Field
                              FadeSlideWidget(
                                delay: const Duration(milliseconds: 300),
                                child: CustomTextField(
                                  label: 'Email or Mobile Number',
                                  hint: 'Enter your email or mobile number',
                                  controller: _emailController,
                                  validator: Validators.emailOrPhone,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Password Field
                              FadeSlideWidget(
                                delay: const Duration(milliseconds: 400),
                                child: CustomTextField(
                                  label: 'Password',
                                  hint: 'Enter your password',
                                  controller: _passwordController,
                                  validator: Validators.password,
                                  obscureText: _obscurePassword,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                      HapticHelper.selection();
                                    },
                                    child: AnimatedRotation(
                                      turns: _obscurePassword ? 0 : 0.5,
                                      duration: AnimationConstants.normal,
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Sign In Button
                              FadeSlideWidget(
                                delay: const Duration(milliseconds: 500),
                                child: CustomButton(
                                  text: 'Sign In',
                                  onPressed: _handleLogin,
                                  isLoading: _isLoading,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'SC',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.black,
            fontSize: 48,
          ),
        ),
        Text(
          'ASA',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.primaryPurple,
            fontSize: 48,
          ),
        ),
      ],
    );
  }
}
