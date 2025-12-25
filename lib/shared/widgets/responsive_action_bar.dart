import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';

class ResponsiveActionBar extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;

  const ResponsiveActionBar({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      // Stack buttons vertically on mobile
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: child,
                ))
            .toList(),
      );
    }

    // Horizontal layout for tablet/desktop
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.end,
      children: children,
    );
  }
}

