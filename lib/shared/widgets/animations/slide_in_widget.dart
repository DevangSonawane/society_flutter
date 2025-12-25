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
    super.key,
    required this.child,
    this.duration = AnimationConstants.normal,
    this.delay = Duration.zero,
    this.direction = SlideDirection.up,
    this.distance = AnimationConstants.slideDistance,
    this.curve = AnimationConstants.enterCurve,
  });

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

