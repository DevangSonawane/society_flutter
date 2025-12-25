import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../../core/constants/animation_constants.dart';
import 'animations/fade_slide_widget.dart';

class ResponsiveStatisticsGrid extends StatelessWidget {
  final List<Widget> children;

  const ResponsiveStatisticsGrid({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    // Add staggered animations to each child
    final animatedChildren = children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(
          bottom: Responsive.isMobile(context) 
              ? Responsive.getCardSpacing(context) 
              : 0,
        ),
        child: FadeSlideWidget(
          delay: AnimationConstants.cardStaggerDelay * index,
          direction: SlideDirection.up,
          child: child,
        ),
      );
    }).toList();

    if (Responsive.isMobile(context)) {
      // Stack vertically on mobile
      return Column(
        children: animatedChildren,
      );
    }

    // Grid layout for tablet and desktop
    // Use Wrap for flexible layout that handles any number of cards
    return Wrap(
      spacing: Responsive.getCardSpacing(context),
      runSpacing: Responsive.getCardSpacing(context),
      children: animatedChildren
          .map((child) => SizedBox(
                width: (MediaQuery.of(context).size.width -
                        Responsive.getScreenPadding(context).left * 2 -
                        Responsive.getCardSpacing(context) * (Responsive.getStatCardsCrossAxisCount(context) - 1)) /
                    Responsive.getStatCardsCrossAxisCount(context),
                child: child,
              ))
          .toList(),
    );
  }
}

