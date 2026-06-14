import 'package:crud_withnodejs/providers/auth_provider.dart';
import 'package:crud_withnodejs/providers/company_provider.dart';
import 'package:crud_withnodejs/screens/auth_gate.dart';
import 'package:crud_withnodejs/screens/detail_screen.dart';
import 'package:crud_withnodejs/screens/form_screen.dart';
import 'package:crud_withnodejs/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          '/form': (context) => const FormScreen(),
          '/detail': (context) => const DetailScreen(),
        },
      ),
    );
  }
}
