import 'package:flutter/material.dart';

import 'package:crud_withnodejs/widgets/skeleton/skeleton_block.dart';
import 'package:crud_withnodejs/widgets/skeleton/skeleton_shimmer.dart';

class CompanyDirectorySummarySkeleton extends StatelessWidget {
  const CompanyDirectorySummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          children: [
            SkeletonBlock(width: 18, height: 18, radius: 6),
            SizedBox(width: 8),
            SkeletonBlock(width: 150, height: 14, radius: 8),
          ],
        ),
      ),
    );
  }
}
