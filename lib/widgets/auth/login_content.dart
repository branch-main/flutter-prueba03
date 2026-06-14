import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/utils/validators.dart';
import 'package:crud_withnodejs/widgets/auth/auth_header.dart';
import 'package:crud_withnodejs/widgets/auth/auth_mode_prompt.dart';
import 'package:crud_withnodejs/widgets/auth/auth_submit_button.dart';
import 'package:crud_withnodejs/widgets/auth/auth_text_field.dart';

class LoginContent extends StatelessWidget {
  final bool isLoading;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final InputDecoration Function({required String hintText, Widget? suffixIcon})
  fieldDecoration;
  final VoidCallback onSubmit;
  final VoidCallback onOpenRegister;
  final VoidCallback onTogglePassword;

  const LoginContent({
    super.key,
    required this.isLoading,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.fieldDecoration,
    required this.onSubmit,
    required this.onOpenRegister,
    required this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: 'Inicia sesión',
            subtitle:
                'Bienvenido de vuelta. Continúa administrando tu directorio empresarial.',
          ),
          const SizedBox(height: 34),
          AuthTextField(
            controller: emailController,
            hintText: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: fieldDecoration(hintText: 'Correo'),
            validator: emailValidator,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: passwordController,
            hintText: 'Contraseña',
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => onSubmit(),
            decoration: fieldDecoration(
              hintText: 'Contraseña',
              suffixIcon: IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.muted,
                ),
              ),
            ),
            validator: passwordValidator,
          ),
          const SizedBox(height: 28),
          AuthSubmitButton(
            label: 'Entrar',
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 26),
          AuthModePrompt(
            text: '¿No tienes cuenta?',
            actionLabel: 'Regístrate',
            isLoading: isLoading,
            onPressed: onOpenRegister,
          ),
        ],
      ),
    );
  }
}
