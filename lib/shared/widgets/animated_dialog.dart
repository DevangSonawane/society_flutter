import 'package:flutter/material.dart';
import '../../core/constants/animation_constants.dart';
import 'animations/fade_in_widget.dart';
import 'animations/scale_animation_widget.dart';

/// Helper function to show an animated dialog
Future<T?> showAnimatedDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = false,
  RouteSettings? routeSettings,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ?? 'Dismiss',
    barrierColor: barrierColor ?? Colors.black54,
    transitionDuration: AnimationConstants.medium,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      Widget dialogChild = child;
      if (useSafeArea) {
        dialogChild = SafeArea(child: child);
      }
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: AnimationConstants.enterCurve,
            ),
          ),
          child: dialogChild,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return child;
    },
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  );
}

/// Animated AlertDialog wrapper
class AnimatedAlertDialog extends StatelessWidget {
  final String? title;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;
  final ShapeBorder? shape;
  final Color? backgroundColor;

  const AnimatedAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.contentPadding,
    this.shape,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title != null
          ? FadeInWidget(
              delay: const Duration(milliseconds: 100),
              child: Text(title!),
            )
          : null,
      content: content != null
          ? FadeInWidget(
              delay: const Duration(milliseconds: 200),
              child: content!,
            )
          : null,
      actions: actions != null
          ? actions!.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              return FadeInWidget(
                delay: Duration(milliseconds: 300 + (index * 50)),
                child: action,
              );
            }).toList()
          : null,
      contentPadding: contentPadding,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: backgroundColor,
    );
  }

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? content,
    List<Widget>? actions,
    EdgeInsetsGeometry? contentPadding,
    ShapeBorder? shape,
    Color? backgroundColor,
    bool barrierDismissible = true,
  }) {
    return showAnimatedDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      child: AnimatedAlertDialog(
        title: title,
        content: content,
        actions: actions,
        contentPadding: contentPadding,
        shape: shape,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

