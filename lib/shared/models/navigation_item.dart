import 'package:flutter/material.dart';

class NavigationItem {
  final String title;
  final IconData icon;
  final String route;
  final List<NavigationItem>? children;
  final bool isExpanded;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.route,
    this.children,
    this.isExpanded = false,
  });

  NavigationItem copyWith({
    String? title,
    IconData? icon,
    String? route,
    List<NavigationItem>? children,
    bool? isExpanded,
  }) {
    return NavigationItem(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      children: children ?? this.children,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

