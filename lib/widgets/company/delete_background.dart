import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';

class DeleteBackground extends StatelessWidget {
  final Alignment alignment;

  const DeleteBackground({super.key, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: alignment,
      child: const Icon(Icons.delete_rounded, color: Colors.white),
    );
  }
}
