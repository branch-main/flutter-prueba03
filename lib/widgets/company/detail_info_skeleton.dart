import 'package:flutter/material.dart';

import 'package:crud_withnodejs/widgets/company/detail_item_skeleton.dart';
import 'package:crud_withnodejs/widgets/skeleton/skeleton_block.dart';
import 'package:crud_withnodejs/widgets/skeleton/skeleton_shimmer.dart';

class DetailInfoSkeleton extends StatelessWidget {
  const DetailInfoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBlock(width: 125, height: 24),
            SizedBox(height: 18),
            DetailItemSkeleton(),
            SizedBox(height: 18),
            DetailItemSkeleton(),
          ],
        ),
      ),
    );
  }
}
