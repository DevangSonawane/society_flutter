# SCASA Flutter App - Modern UI/UX Enhancement Documentation

## 📋 Table of Contents
1. [Package Setup](#package-setup)
2. [Animation System Architecture](#animation-system-architecture)
3. [Reusable Animation Widgets](#reusable-animation-widgets)
4. [Screen Implementations](#screen-implementations)
5. [Global Enhancements](#global-enhancements)
6. [Implementation Checklist](#implementation-checklist)

---

## 1. Package Setup

### Step 1: Add Dependencies to `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Existing dependencies
  # ... your current packages ...
  
  # Animation packages
  flutter_animate: ^4.5.0
  lottie: ^3.1.0
  shimmer: ^3.0.0
  
  # Interaction packages
  flutter_slidable: ^3.0.1
  vibration: ^1.8.4
  
  # Visual effects
  confetti: ^0.7.0
  
  # UI Components
  flutter_spinkit: ^5.2.0
  page_transition: ^2.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### Step 2: Install Packages

```bash
flutter pub get
```

---

## 2. Animation System Architecture

### Create Animation Constants

Create file: `lib/core/constants/animation_constants.dart`

```dart
import 'package:flutter/material.dart';

class AnimationConstants {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration verySlow = Duration(milliseconds: 1200);
  
  // Curve constants
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve enterCurve = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;
  static const Curve bounceCurve = Curves.elasticOut;
  
  // Animation values
  static const double scaleDown = 0.95;
  static const double scaleUp = 1.05;
  static const double slideDistance = 50.0;
  
  // Stagger delays
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const Duration cardStaggerDelay = Duration(milliseconds: 100);
}
```

---

## 3. Reusable Animation Widgets

### 3.1 Fade In Animation

Create file: `lib/shared/widgets/animations/fade_in_widget.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/animation_constants.dart';

class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  
  const FadeInWidget({
    Key? key,
    required this.child,
    this.duration = AnimationConstants.normal,
    this.delay = Duration.zero,
    this.curve = AnimationConstants.defaultCurve,
  }) : super(key: key);

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
```

### 3.2 Slide In Animation

Create file: `lib/shared/widgets/animations/slide_in_widget.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/animation_constants.dart';

enum SlideDirection { left, right, up, down }

class SlideInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final SlideDirection direction;
  final double distance;
  final Curve curve;
  
  const SlideInWidget({
    Key? key,
    required this.child,
    this.duration = AnimationConstants.normal,
    this.delay = Duration.zero,
    this.direction = SlideDirection.up,
    this.distance = AnimationConstants.slideDistance,
    this.curve = AnimationConstants.enterCurve,
  }) : super(key: key);

  @override
  State<SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<SlideInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    Offset begin;
    switch (widget.direction) {
      case SlideDirection.left:
        begin = Offset(-widget.distance / 100, 0.0);
        break;
      case SlideDirection.right:
        begin = Offset(widget.distance / 100, 0.0);
        break;
      case SlideDirection.up:
        begin = Offset(0.0, widget.distance / 100);
        break;
      case SlideDirection.down:
        begin = Offset(0.0, -widget.distance / 100);
        break;
    }
    
    _animation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}
```

### 3.3 Scale Animation

Create file: `lib/shared/widgets/animations/scale_animation_widget.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/animation_constants.dart';

class ScaleAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double beginScale;
  final double endScale;
  final Curve curve;
  
  const ScaleAnimationWidget({
    Key? key,
    required this.child,
    this.duration = AnimationConstants.normal,
    this.delay = Duration.zero,
    this.beginScale = 0.8,
    this.endScale = 1.0,
    this.curve = AnimationConstants.defaultCurve,
  }) : super(key: key);

  @override
  State<ScaleAnimationWidget> createState() => _ScaleAnimationWidgetState();
}

class _ScaleAnimationWidgetState extends State<ScaleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
```

### 3.4 Combined Fade & Slide Animation

Create file: `lib/shared/widgets/animations/fade_slide_widget.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/animation_constants.dart';
import 'slide_in_widget.dart';

class FadeSlideWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final SlideDirection direction;
  final double distance;
  
  const FadeSlideWidget({
    Key? key,
    required this.child,
    this.duration = AnimationConstants.normal,
    this.delay = Duration.zero,
    this.direction = SlideDirection.up,
    this.distance = AnimationConstants.slideDistance,
  }) : super(key: key);

  @override
  State<FadeSlideWidget> createState() => _FadeSlideWidgetState();
}

class _FadeSlideWidgetState extends State<FadeSlideWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationConstants.defaultCurve,
    ));
    
    Offset begin;
    switch (widget.direction) {
      case SlideDirection.left:
        begin = Offset(-widget.distance / 100, 0.0);
        break;
      case SlideDirection.right:
        begin = Offset(widget.distance / 100, 0.0);
        break;
      case SlideDirection.up:
        begin = Offset(0.0, widget.distance / 100);
        break;
      case SlideDirection.down:
        begin = Offset(0.0, -widget.distance / 100);
        break;
    }
    
    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AnimationConstants.enterCurve,
    ));
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
```

### 3.5 Shimmer Loading Widget

Create file: `lib/shared/widgets/animations/shimmer_loading.dart`

```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  
  const ShimmerLoading({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Card Shimmer
class CardShimmer extends StatelessWidget {
  const CardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(width: 150, height: 20),
          const SizedBox(height: 8),
          ShimmerLoading(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          ShimmerLoading(width: 200, height: 16),
        ],
      ),
    );
  }
}

// Table Row Shimmer
class TableRowShimmer extends StatelessWidget {
  const TableRowShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          ShimmerLoading(width: 100, height: 16),
          const SizedBox(width: 16),
          Expanded(child: ShimmerLoading(width: double.infinity, height: 16)),
          const SizedBox(width: 16),
          ShimmerLoading(width: 80, height: 16),
          const SizedBox(width: 16),
          ShimmerLoading(width: 60, height: 16),
        ],
      ),
    );
  }
}
```

### 3.6 Animated Counter

Create file: `lib/shared/widgets/animations/animated_counter.dart`

```dart
import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? textStyle;
  final String prefix;
  final String suffix;
  
  const AnimatedCounter({
    Key? key,
    required this.value,
    this.duration = const Duration(milliseconds: 1500),
    this.textStyle,
    this.prefix = '',
    this.suffix = '',
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> {
  int _displayValue = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animateCounter();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animateCounter();
    }
  }

  void _animateCounter() {
    _timer?.cancel();
    
    const steps = 60;
    final increment = widget.value / steps;
    int currentStep = 0;
    
    _timer = Timer.periodic(
      Duration(milliseconds: widget.duration.inMilliseconds ~/ steps),
      (timer) {
        if (currentStep >= steps) {
          timer.cancel();
          if (mounted) {
            setState(() => _displayValue = widget.value);
          }
        } else {
          if (mounted) {
            setState(() {
              _displayValue = (increment * currentStep).round();
            });
          }
          currentStep++;
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.prefix}$_displayValue${widget.suffix}',
      style: widget.textStyle,
    );
  }
}
```

### 3.7 Pulse Animation

Create file: `lib/shared/widgets/animations/pulse_widget.dart`

```dart
import 'package:flutter/material.dart';

class PulseWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool infinite;
  
  const PulseWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.infinite = true,
  }) : super(key: key);

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.infinite) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
```

### 3.8 Staggered List Animation

Create file: `lib/shared/widgets/animations/staggered_list.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/constants/animation_constants.dart';

class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Axis direction;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  
  const StaggeredList({
    Key? key,
    required this.children,
    this.staggerDelay = AnimationConstants.staggerDelay,
    this.direction = Axis.vertical,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: List.generate(
        children.length,
        (index) => FadeSlideWidget(
          delay: staggerDelay * index,
          child: children[index],
        ),
      ),
    );
  }
}

// Import this at the top of the file
import 'fade_slide_widget.dart';
```

---

## 4. Screen Implementations

### 4.1 Enhanced Login Screen

Update `lib/features/auth/presentation/screens/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/animations/fade_in_widget.dart';
import '../../../../shared/widgets/animations/scale_animation_widget.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../core/constants/animation_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  late AnimationController _buttonScaleController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Button press animation controller
    _buttonScaleController = AnimationController(
      duration: AnimationConstants.fast,
      vsync: this,
      value: 1.0,
    );
    
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: AnimationConstants.scaleDown,
    ).animate(CurvedAnimation(
      parent: _buttonScaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _buttonScaleController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      // Add your login logic here
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        setState(() => _isLoading = false);
        // Navigate to dashboard on success
        // Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }

  void _onButtonTapDown(TapDownDetails details) {
    _buttonScaleController.reverse();
    HapticFeedback.lightImpact();
  }

  void _onButtonTapUp(TapUpDetails details) {
    _buttonScaleController.forward();
    _handleLogin();
  }

  void _onButtonTapCancel() {
    _buttonScaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPurple.withOpacity(0.05),
              AppColors.white,
              AppColors.primaryPurpleLight.withOpacity(0.05),
            ],
          ),
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
                      
                      const SizedBox(height: 48),
                      
                      // Email Field
                      FadeSlideWidget(
                        delay: const Duration(milliseconds: 300),
                        child: CustomTextField(
                          controller: _emailController,
                          label: 'Email or Mobile Number',
                          hint: 'Enter email or mobile number',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email or mobile number';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Password Field
                      FadeSlideWidget(
                        delay: const Duration(milliseconds: 400),
                        child: CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter password',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                              HapticFeedback.selectionClick();
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Sign In Button
                      FadeSlideWidget(
                        delay: const Duration(milliseconds: 500),
                        child: _buildAnimatedButton(),
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
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        Text(
          'ASA',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedButton() {
    return GestureDetector(
      onTapDown: _isLoading ? null : _onButtonTapDown,
      onTapUp: _isLoading ? null : _onButtonTapUp,
      onTapCancel: _onButtonTapCancel,
      child: AnimatedBuilder(
        animation: _buttonScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurple,
                    AppColors.primaryPurpleLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 4.2 Enhanced Statistics Card

Update `lib/shared/widgets/statistics_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'animations/fade_slide_widget.dart';
import 'animations/animated_counter.dart';
import 'animations/pulse_widget.dart';

class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color borderColor;
  final Color valueColor;
  final IconData icon;
  final bool showTrend;
  final String? trendText;
  final bool isPulse;
  final Duration? animationDelay;
  
  const StatisticsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.borderColor,
    required this.valueColor,
    required this.icon,
    this.showTrend = false,
    this.trendText,
    this.isPulse = false,
    this.animationDelay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeSlideWidget(
      delay: animationDelay ?? Duration.zero,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            top: BorderSide(color: borderColor, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and Title Row
              Row(
                children: [
                  isPulse
                      ? PulseWidget(
                          child: _buildIcon(),
                        )
                      : _buildIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Value
              _buildValue(),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
              
              // Trend Indicator
              if (showTrend && trendText != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      size: 14,
                      color: AppColors.successGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trendText!,
                      style: TextStyle(
                        color: AppColors.successGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: borderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: borderColor,
        size: 24,
      ),
    );
  }

  Widget _buildValue() {
    // Check if value is a number
    final numValue = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    
    if (numValue != null) {
      // Animated counter for numbers
      return AnimatedCounter(
        value: numValue,
        textStyle: TextStyle(
          color: valueColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        prefix: value.startsWith('₹') ? '₹' : '',
      );
    } else {
      // Regular text for non-numbers
      return Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }
}
```

---

### 4.3 Enhanced Dashboard Screen

Update `lib/features/dashboard/presentation/screens/dashboard_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animations/fade_slide_widget.dart';
import '../../../../shared/widgets/animations/fade_in_widget.dart';
import '../../../../core/constants/animation_constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.width > 768 ? 24 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card with Animation
          FadeSlideWidget(
            duration: AnimationConstants.medium,
            child: _buildWelcomeCard(context),
          ),
          
          const SizedBox(height: 24),
          
          // SCASA Description Card
          FadeSlideWidget(
            delay: const Duration(milliseconds: 200),
            child: _buildDescriptionCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPurple,
            AppColors.primaryPurpleLight,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInWidget(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'Welcome back, Happy Valley!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInWidget(
            delay: const Duration(milliseconds: 600),
            child: Text(
              'Here\'s what\'s happening in your society today.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCASA',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Society Comprehensive Administration System Application',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### 4.4 Enhanced Custom Button

Update `lib/shared/widgets/custom_button.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/animation_constants.dart';

enum ButtonType { primary, secondary, text }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonType type;
  final bool isLoading;
  final bool fullWidth;
  
  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.fullWidth = true,
  }) : super(key: key);

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationConstants.fast,
      vsync: this,
      value: 1.0,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AnimationConstants.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          height: 56,
          padding: widget.fullWidth ? null : const EdgeInsets.symmetric(horizontal: 24),
          decoration: _getDecoration(),
          child: Center(
            child: widget.isLoading
                ? _buildLoadingIndicator()
                : _buildContent(),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (widget.type) {
      case ButtonType.primary:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryPurple,
              AppColors.primaryPurpleLight,
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
      
      case ButtonType.secondary:
        return BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppColors.borderLight,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        );
      
      case ButtonType.text:
        return const BoxDecoration();
    }
  }

  Widget _buildLoadingIndicator() {
    final color = widget.type == ButtonType.primary
        ? Colors.white
        : AppColors.primaryPurple;
    
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: 2.5,
      ),
    );
  }

  Widget _buildContent() {
    final textStyle = TextStyle(
      color: widget.type == ButtonType.primary
          ? Colors.white
          : AppColors.primaryPurple,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            color: textStyle.color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(widget.text, style: textStyle),
        ],
      );
    }
    
    return Text(widget.text, style: textStyle);
  }
}
```

---

### 4.5 Enhanced Custom TextField

Update `lib/shared/widgets/custom_text_field.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final int? maxLines;
  
  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.onChanged,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  late AnimationController _controller;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: _isFocused
                  ? AppColors.primaryPurple
                  : AppColors.textSecondary,
              fontSize: _isFocused ? 14 : 14,
              fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
            ),
            child: Text(widget.label!),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
          child: TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            maxLines: widget.maxLines,
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: widget.readOnly
                  ? AppColors.backgroundLight
                  : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.borderLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.borderLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.primaryPurple,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.errorRed,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.errorRed,
                  width: 2.0,
                ),
              ),
            ),
            onFocusChange: (hasFocus) {
              setState(() {
                _isFocused = hasFocus;
              });
              if (hasFocus) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
          ),
        ),
      ],
    );
  }
}

// Note: Add this extension if not already present
extension TextFormFieldFocus on TextFormField {
  void onFocusChange(Function(bool) callback) {
    // This is a placeholder - implement focus listener in the widget itself
  }
}
```

---

## 5. Global Enhancements

### 5.1 Custom Page Transitions

Create file: `lib/core/routes/page_transitions.dart`

```dart
import 'package:flutter/material.dart';

class FadeSlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  FadeSlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.05);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            
            var tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            
            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                .animate(animation);
            
            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: offsetAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  ScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );
            
            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
                .animate(animation);
            
            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

// Usage in navigation:
// Navigator.of(context).push(
//   FadeSlidePageRoute(page: DashboardScreen()),
// );
```

### 5.2 Enhanced Snackbar

Create file: `lib/shared/widgets/custom_snackbar.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum SnackbarType { success, error, warning, info }

class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIcon(type),
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getColor(type),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration,
      animation: CurvedAnimation(
        parent: kAlwaysCompleteAnimation,
        curve: Curves.easeOutCubic,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning;
      case SnackbarType.info:
        return Icons.info;
    }
  }

  static Color _getColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return AppColors.successGreen;
      case SnackbarType.error:
        return AppColors.errorRed;
      case SnackbarType.warning:
        return AppColors.warningYellow;
      case SnackbarType.info:
        return AppColors.infoblue;
    }
  }
}

// Usage:
// CustomSnackbar.show(
//   context,
//   message: 'Login successful!',
//   type: SnackbarType.success,
// );
```

### 5.3 Haptic Feedback Helper

Create file: `lib/core/utils/haptic_helper.dart`

```dart
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticHelper {
  static Future<void> light() async {
    if (await Vibration.hasVibrator() ?? false) {
      await HapticFeedback.lightImpact();
    }
  }

  static Future<void> medium() async {
    if (await Vibration.hasVibrator() ?? false) {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> heavy() async {
    if (await Vibration.hasVibrator() ?? false) {
      await HapticFeedback.heavyImpact();
    }
  }

  static Future<void> selection() async {
    if (await Vibration.hasVibrator() ?? false) {
      await HapticFeedback.selectionClick();
    }
  }

  static Future<void> success() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(pattern: [0, 100, 50, 100]);
    }
  }

  static Future<void> error() async {
    if (await Vibration.hasVibrator() ?? false) {
      await Vibration.vibrate(pattern: [0, 50, 50, 50, 50, 50]);
    }
  }
}

// Usage:
// await HapticHelper.light();
// await HapticHelper.success();
```

---

## 6. Implementation Checklist

### Phase 1: Foundation (Week 1)
- [ ] Install all packages from `pubspec.yaml`
- [ ] Create `animation_constants.dart`
- [ ] Create all animation widgets in `shared/widgets/animations/`
  - [ ] `fade_in_widget.dart`
  - [ ] `slide_in_widget.dart`
  - [ ] `scale_animation_widget.dart`
  - [ ] `fade_slide_widget.dart`
  - [ ] `shimmer_loading.dart`
  - [ ] `animated_counter.dart`
  - [ ] `pulse_widget.dart`
  - [ ] `staggered_list.dart`
- [ ] Create `page_transitions.dart`
- [ ] Create `custom_snackbar.dart`
- [ ] Create `haptic_helper.dart`

### Phase 2: Core Screens (Week 2)
- [ ] Update `login_screen.dart` with animations
- [ ] Update `dashboard_screen.dart` with animations
- [ ] Update `statistics_card.dart` with counter animation
- [ ] Update `custom_button.dart` with scale animation
- [ ] Update `custom_text_field.dart` with focus animation
- [ ] Test all animations on login and dashboard

### Phase 3: Navigation & Lists (Week 3)
- [ ] Add drawer opening animation
- [ ] Add menu item hover effects (desktop)
- [ ] Add active item slide-in animation
- [ ] Implement shimmer loading for all list screens
- [ ] Add staggered animation to list items
- [ ] Add swipe-to-delete animations
- [ ] Test navigation transitions

### Phase 4: Forms & Dialogs (Week 4)
- [ ] Add field focus animations to all forms
- [ ] Add validation shake animation
- [ ] Enhance dialog transitions
- [ ] Add success/error animations
- [ ] Implement progress indicators
- [ ] Add micro-interactions to all buttons

### Phase 5: Polish & Optimization (Ongoing)
- [ ] Profile with Flutter DevTools
- [ ] Optimize animation performance
- [ ] Add `RepaintBoundary` where needed
- [ ] Test on multiple devices
- [ ] Adjust animation timings based on feedback
- [ ] Document any custom animations

---

## 7. Testing Guidelines

### Animation Testing Checklist

```dart
// Add this to test animations
void main() {
  testWidgets('Button scale animation test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CustomButton(
          text: 'Test Button',
          onPressed: () {},
        ),
      ),
    ));

    // Test tap down
    await tester.press(find.byType(CustomButton));
    await tester.pump(const Duration(milliseconds: 100));
    
    // Verify scale animation occurred
    // Add assertions here

    await tester.pumpAndSettle();
  });
}
```

### Performance Testing

1. Run with performance overlay:
```dart
void main() {
  runApp(
    MaterialApp(
      showPerformanceOverlay: true,
      home: YourApp(),
    ),
  );
}
```

2. Check for jank:
- Open Flutter DevTools
- Navigate to Performance tab
- Record interactions
- Look for frames > 16ms

3. Profile memory:
- Check for animation controller leaks
- Verify all controllers are disposed
- Monitor memory during navigation

---

## 8. Common Issues & Solutions

### Issue 1: Animations Not Playing
**Solution:**
- Ensure `TickerProviderStateMixin` is added to State class
- Check that animations start with `controller.forward()`
- Verify widget is mounted before starting animation

### Issue 2: Jank During Animation
**Solution:**
- Use `RepaintBoundary` for complex widgets
- Reduce simultaneous animations
- Use `const` constructors where possible

### Issue 3: Controller Not Disposed
**Solution:**
```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

### Issue 4: Animation Restart on Rebuild
**Solution:**
- Initialize controllers in `initState`
- Use `didUpdateWidget` to handle prop changes
- Check `mounted` before starting animations

---

## 9. Best Practices

1. **Always dispose controllers:**
```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

2. **Use animation constants:**
```dart
// Instead of hardcoding durations
duration: AnimationConstants.normal,
```

3. **Add delays for staggered animations:**
```dart
delay: AnimationConstants.staggerDelay * index,
```

4. **Use curves for natural motion:**
```dart
curve: Curves.easeOutCubic,
```

5. **Check mounted state:**
```dart
if (mounted) {
  _controller.forward();
}
```

6. **Use const constructors:**
```dart
const SizedBox(height: 16),
```

7. **Limit animation complexity:**
- Max 3-4 simultaneous animations
- Keep duration under 1 second
- Use appropriate curves

---

## 10. Resources

### Flutter Animation Documentation
- https://docs.flutter.dev/development/ui/animations
- https://api.flutter.dev/flutter/animation/AnimationController-class.html

### Packages Documentation
- flutter_animate: https://pub.dev/packages/flutter_animate
- lottie: https://pub.dev/packages/lottie
- shimmer: https://pub.dev/packages/shimmer

### Inspiration
- Material Design Motion: https://m3.material.io/styles/motion
- Dribbble: https://dribbble.com/tags/app_animation
- FlutterAwesome: https://flutterawesome.com/tag/animation/

---

## Quick Start Example

Here's a complete example to get started: