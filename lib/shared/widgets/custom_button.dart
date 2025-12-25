import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/animation_constants.dart';
import '../../core/utils/haptic_helper.dart';

enum ButtonType { primary, secondary, text }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonType type;
  final bool isLoading;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.fullWidth = true,
  });

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
      HapticHelper.light();
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
          height: 52,
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
          borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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

