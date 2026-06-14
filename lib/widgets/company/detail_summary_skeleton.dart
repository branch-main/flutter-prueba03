import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/widgets/skeleton/skeleton_block.dart';
import 'package:crud_withnodejs/widgets/skeleton/skeleton_shimmer.dart';

class DetailSummarySkeleton extends StatelessWidget {
  const DetailSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.card,
      ),
      child: SkeletonShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBlock(width: 190, height: 22),
            const SizedBox(height: 12),
            const Row(
              children: [
                SkeletonBlock(width: 18, height: 18, radius: 6),
                SizedBox(width: 8),
                SkeletonBlock(width: 120, height: 15),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBlock(width: 60, height: 14),
                        SizedBox(height: 6),
                        SkeletonBlock(width: 150, height: 14),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  SkeletonBlock(width: 48, height: 28, radius: 14),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(child: SkeletonBlock(height: 48, radius: 16)),
                SizedBox(width: 10),
                Expanded(child: SkeletonBlock(height: 48, radius: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
