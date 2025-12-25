import 'package:flutter/material.dart';
import '../../../core/constants/animation_constants.dart';
import 'fade_slide_widget.dart';

class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Axis direction;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  
  const StaggeredList({
    super.key,
    required this.children,
    this.staggerDelay = AnimationConstants.staggerDelay,
    this.direction = Axis.vertical,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

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

