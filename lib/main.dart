import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crud_withnodejs/providers/auth_provider.dart';
import 'package:crud_withnodejs/providers/company_provider.dart';
import 'package:crud_withnodejs/core/auth_gate.dart';
import 'package:crud_withnodejs/screens/detail_screen.dart';
import 'package:crud_withnodejs/screens/form_screen.dart';
import 'package:crud_withnodejs/screens/login_screen.dart';
import 'package:crud_withnodejs/screens/register_screen.dart';
import 'package:crud_withnodejs/core/app_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..loadSession(),
        ),
        ChangeNotifierProvider(create: (context) => CompanyProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Registro de Empresas',
        theme: AppTheme.light(),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthGate(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/form': (context) => const FormScreen(),
          '/detail': (context) => const DetailScreen(),
        },
      ),
    );
  }
}
