import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';

class HomeTopBar extends StatelessWidget {
  final String userName;
  final VoidCallback onLogout;

  const HomeTopBar({super.key, required this.userName, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buen día', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        IconButton.filled(
          tooltip: 'Cerrar sesión',
          onPressed: onLogout,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
          ),
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}
