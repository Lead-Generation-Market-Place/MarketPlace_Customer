import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerListTileWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final int? defultCount;
  const ShimmerListTileWidget({
    super.key,
    this.height,
    this.width,
    this.defultCount,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? MediaQuery.of(context).size.height / 12;
    final w = width ?? MediaQuery.of(context).size.width;
    final count = defultCount ?? 12;
    return SizedBox(
      width: w,
      child: Column(
        children: List.generate(count, (index) => _buildShimmerTile(h, w)),
      ),
    );
  }

  Widget _buildShimmerTile(double h, double w) {
    return SizedBox(
      height: h,
      width: w,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: w * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 12,
                    width: w * 0.35,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 10,
                    width: w * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
