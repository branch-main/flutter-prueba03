import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';

class SkeletonShimmer extends StatefulWidget {
  final Widget child;

  const SkeletonShimmer({super.key, required this.child});

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final width = bounds.width <= 0 ? 1.0 : bounds.width;
            final shimmerWidth = width * 0.72;
            final left =
                -shimmerWidth + (width + shimmerWidth * 2) * _controller.value;

            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.surfaceAlt.withValues(alpha: 0.7),
                Colors.white.withValues(alpha: 0.95),
                AppColors.surfaceAlt.withValues(alpha: 0.7),
              ],
            ).createShader(Rect.fromLTWH(left, 0, shimmerWidth, bounds.height));
          },
          child: child,
        );
      },
    );
  }
}
