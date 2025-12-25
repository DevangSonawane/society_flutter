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
    super.key,
    required this.child,
    this.duration = AnimationConstants.normal,
    this.delay = Duration.zero,
    this.beginScale = 0.8,
    this.endScale = 1.0,
    this.curve = AnimationConstants.defaultCurve,
  });

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

