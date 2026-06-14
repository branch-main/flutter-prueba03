import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';

class CompanyStatusToggle extends StatelessWidget {
  final bool isActive;
  final bool isLoading;
  final VoidCallback onChanged;

  const CompanyStatusToggle({
    super.key,
    required this.isActive,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive
                      ? 'Activa en el directorio'
                      : 'Inactiva en el directorio',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch.adaptive(
              value: isActive,
              activeThumbColor: AppColors.blue,
              onChanged: (_) => onChanged(),
            ),
        ],
      ),
    );
  }
}
