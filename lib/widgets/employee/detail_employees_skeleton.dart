import 'package:flutter/material.dart';

import 'package:crud_withnodejs/widgets/employee/employee_card_skeleton.dart';
import 'package:crud_withnodejs/widgets/skeleton/skeleton_block.dart';
import 'package:crud_withnodejs/widgets/skeleton/skeleton_shimmer.dart';

class DetailEmployeesSkeleton extends StatelessWidget {
  const DetailEmployeesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBlock(width: 110, height: 24),
            SizedBox(height: 18),
            EmployeeCardSkeleton(),
            SizedBox(height: 20),
            EmployeeCardSkeleton(),
          ],
        ),
      ),
    );
  }
}
