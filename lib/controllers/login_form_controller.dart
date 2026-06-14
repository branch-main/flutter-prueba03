import 'package:flutter/material.dart';

class LoginFormController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool get obscurePassword => _obscurePassword;
  String get email => emailController.text.trim();
  String get password => passwordController.text;

  bool validate() => formKey.currentState?.validate() ?? false;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
