import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';

class EmployeeMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const EmployeeMeta({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.muted),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
