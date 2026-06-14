import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';

class CompanyDirectorySummary extends StatelessWidget {
  final int total;
  final int visible;
  final bool isSearching;

  const CompanyDirectorySummary({
    super.key,
    required this.total,
    required this.visible,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final text = isSearching
        ? '$visible ${_matchesLabel(visible)} encontradas'
        : _registeredCompaniesLabel(total);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Row(
        children: [
          Icon(
            isSearching ? Icons.manage_search_rounded : Icons.apartment_rounded,
            size: 18,
            color: AppColors.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

String _matchesLabel(int count) =>
    count == 1 ? 'coincidencia' : 'coincidencias';

String _registeredCompaniesLabel(int count) {
  return count == 1 ? '1 empresa registrada' : '$count empresas registradas';
}
