import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  
  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// Card Shimmer
class CardShimmer extends StatelessWidget {
  const CardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(width: 150, height: 20),
          const SizedBox(height: 8),
          ShimmerLoading(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          ShimmerLoading(width: 200, height: 16),
        ],
      ),
    );
  }
}

// Table Row Shimmer
class TableRowShimmer extends StatelessWidget {
  const TableRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          ShimmerLoading(width: 100, height: 16),
          const SizedBox(width: 16),
          Expanded(child: ShimmerLoading(width: double.infinity, height: 16)),
          const SizedBox(width: 16),
          ShimmerLoading(width: 80, height: 16),
          const SizedBox(width: 16),
          ShimmerLoading(width: 60, height: 16),
        ],
      ),
    );
  }
}

