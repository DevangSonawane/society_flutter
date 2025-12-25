import 'package:flutter/material.dart';
import '../../../core/constants/animation_constants.dart';
import 'slide_in_widget.dart';

// Re-export SlideDirection for convenience
export 'slide_in_widget.dart' show SlideDirection;

class FadeSlideWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final SlideDirection direction;
  final double distance;
  
  const FadeSlideWidget({
    super.key,
    required this.child,
    this.duration = AnimationConstants.normal,
    this.delay = Duration.zero,
    this.direction = SlideDirection.up,
    this.distance = AnimationConstants.slideDistance,
  });

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

