import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/widgets/skeleton/skeleton_block.dart';
import 'package:crud_withnodejs/widgets/skeleton/skeleton_shimmer.dart';

class CompanyCardSkeleton extends StatelessWidget {
  const CompanyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: const SkeletonShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(width: 170, height: 18),
                  SizedBox(height: 8),
                  SkeletonBlock(width: 120, height: 14),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      SkeletonBlock(width: 86, height: 30, radius: 14),
                      SizedBox(width: 8),
                      SkeletonBlock(width: 120, height: 30, radius: 14),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            SkeletonBlock(width: 38, height: 38, radius: 19),
          ],
        ),
      ),
    );
  }
}
