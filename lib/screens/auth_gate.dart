import 'package:crud_withnodejs/providers/auth_provider.dart';
import 'package:crud_withnodejs/screens/list_screen.dart';
import 'package:crud_withnodejs/screens/login_screen.dart';
import 'package:crud_withnodejs/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: AppGradients.brand),
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const ListScreen();
    }

    return const LoginScreen();
  }
}
