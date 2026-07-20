import 'package:jobUp24/core/extensions/extensions.dart';
import 'package:jobUp24/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// Asosiy ranglar
final baseShimmerColor = Colors.grey[800]!;
final highlightShimmerColor = Colors.grey[700]!;

Widget listViewShimmer({required BuildContext context, double? height, int? itemCount, EdgeInsetsGeometry? padding}) {
  return ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    padding: padding,
    shrinkWrap: true,
    itemCount: itemCount ?? 10,
    itemBuilder: (context, index) {
      return const ShimmerListItem();
    },
  );
}

Widget shimmerContainer(double width, {double? height, double? borderRadius}) {
  return Shimmer.fromColors(
    baseColor: baseShimmerColor,
    highlightColor: highlightShimmerColor,
    child: Container(
      width: width,
      height: height ?? 14,
      decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(borderRadius ?? 4)),
    ),
  );
}

class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar (chapdagi doira)
              Shimmer.fromColors(
                baseColor: baseShimmerColor,
                highlightColor: highlightShimmerColor,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: 12),
              shimmerContainer(120),
              const Spacer(),
              shimmerContainer(50),
            ],
          ),
          10.height,
          Row(children: [shimmerContainer(150), const Spacer(), shimmerContainer(80)]),
        ],
      ),
    );
  }
}

class DashboardDataShimmer extends StatelessWidget {
  const DashboardDataShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: shimmerContainer(getScreenWidth(context), height: 77, borderRadius: 12)),
            8.width,
            Expanded(child: shimmerContainer(getScreenWidth(context), height: 77, borderRadius: 12)),
          ],
        ),
        6.height,
        Row(
          children: [
            Expanded(child: shimmerContainer(getScreenWidth(context), height: 77, borderRadius: 12)),
            8.width,
            Expanded(child: shimmerContainer(getScreenWidth(context), height: 77, borderRadius: 12)),
          ],
        ),
        6.height,
        Row(
          children: [
            Expanded(child: shimmerContainer(getScreenWidth(context), height: 77, borderRadius: 12)),
            8.width,
            Expanded(child: shimmerContainer(getScreenWidth(context), height: 77, borderRadius: 12)),
          ],
        ),
      ],
    );
  }
}
