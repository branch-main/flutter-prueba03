import 'package:flutter/material.dart';

import 'package:crud_withnodejs/widgets/skeleton/skeleton_block.dart';

class DetailItemSkeleton extends StatelessWidget {
  const DetailItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(width: 24, height: 24, radius: 8),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBlock(width: 90, height: 13),
              SizedBox(height: 8),
              SkeletonBlock(width: 180, height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
