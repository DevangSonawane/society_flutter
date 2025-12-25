import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import '../../core/constants/animation_constants.dart';
import 'animations/fade_slide_widget.dart';
import 'animations/fade_in_widget.dart';

class ResponsiveTable extends StatelessWidget {
  final List<String> columns;
  final List<DataRow> rows;
  final List<Widget>? mobileCards;

  const ResponsiveTable({
    super.key,
    required this.columns,
    required this.rows,
    this.mobileCards,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context) && mobileCards != null) {
      // Card-based layout for mobile with staggered animations
      return Column(
        children: mobileCards!
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final card = entry.value;
              return FadeSlideWidget(
                delay: AnimationConstants.staggerDelay * index,
                direction: SlideDirection.up,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: card,
                ),
              );
            })
            .toList(),
      );
    }

    // Table layout for tablet/desktop with horizontal scroll and fade-in animation
    return FadeInWidget(
      delay: const Duration(milliseconds: 200),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns.map((column) => DataColumn(label: Text(column))).toList(),
          rows: rows,
        ),
      ),
    );
  }
}


