import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crud_withnodejs/controllers/register_form_controller.dart';
import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/providers/auth_provider.dart';
import 'package:crud_withnodejs/utils/dialog_utils.dart';
import 'package:crud_withnodejs/widgets/auth/register_content.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _controller = RegisterFormController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_controller.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _controller.email,
      password: _controller.password,
      name: _controller.name,
    );

    if (!mounted) return;

    if (!success) {
      showAppError(
        context,
        authProvider.errorMessage ?? 'No se pudo crear la cuenta.',
      );
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  void _openLogin() {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  InputDecoration _fieldDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return RegisterContent(
                    isLoading: authProvider.isLoading,
                    formKey: _controller.formKey,
                    nameController: _controller.nameController,
                    emailController: _controller.emailController,
                    passwordController: _controller.passwordController,
                    confirmPasswordController:
                        _controller.confirmPasswordController,
                    obscurePassword: _controller.obscurePassword,
                    obscureConfirmPassword: _controller.obscureConfirmPassword,
                    fieldDecoration: _fieldDecoration,
                    onSubmit: _submit,
                    onOpenLogin: _openLogin,
                    onTogglePassword: _controller.togglePasswordVisibility,
                    onToggleConfirmPassword:
                        _controller.toggleConfirmPasswordVisibility,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
