import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? textStyle;
  final String prefix;
  final String suffix;
  
  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1500),
    this.textStyle,
    this.prefix = '',
    this.suffix = '',
  });

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

