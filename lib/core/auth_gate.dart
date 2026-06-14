import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/providers/auth_provider.dart';
import 'package:crud_withnodejs/screens/list_screen.dart';
import 'package:crud_withnodejs/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.hasLoadedSession) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: AppColors.blue)),
      );
    }

    if (authProvider.isAuthenticated) {
      return const ListScreen();
    }

    return const LoginScreen();
  }
}
