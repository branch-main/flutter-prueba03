import 'package:flutter/material.dart';

import 'package:crud_withnodejs/widgets/skeleton/skeleton_block.dart';

class EmployeeCardSkeleton extends StatelessWidget {
  const EmployeeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBlock(width: 44, height: 44, radius: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(width: 170, height: 17),
                  SizedBox(height: 8),
                  SkeletonBlock(width: 120, height: 14),
                ],
              ),
            ),
            SizedBox(width: 12),
            SkeletonBlock(width: 38, height: 38, radius: 19),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            SkeletonBlock(width: 105, height: 16),
            SizedBox(width: 14),
            SkeletonBlock(width: 150, height: 16),
          ],
        ),
      ],
    );
  }
}
