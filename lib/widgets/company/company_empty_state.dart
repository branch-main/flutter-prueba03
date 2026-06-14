import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';

class CompanyEmptyState extends StatelessWidget {
  final bool isSearching;

  const CompanyEmptyState({super.key, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSearching
                    ? Icons.manage_search_rounded
                    : Icons.business_outlined,
                color: AppColors.blue,
                size: 42,
              ),
              const SizedBox(height: 18),
              Text(
                isSearching ? 'Sin resultados' : 'Aún no hay empresas',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                isSearching
                    ? 'Prueba con otro nombre o RUC para encontrar coincidencias.'
                    : 'Crea tu primera empresa y empieza a organizar el directorio.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
