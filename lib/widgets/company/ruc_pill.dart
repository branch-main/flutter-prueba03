import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';

class RucPill extends StatelessWidget {
  final String taxId;

  const RucPill({super.key, required this.taxId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'RUC $taxId',
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
