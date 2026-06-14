import 'package:flutter/material.dart';

import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/utils/validators.dart';
import 'package:crud_withnodejs/widgets/auth/auth_header.dart';
import 'package:crud_withnodejs/widgets/auth/auth_mode_prompt.dart';
import 'package:crud_withnodejs/widgets/auth/auth_submit_button.dart';
import 'package:crud_withnodejs/widgets/auth/auth_text_field.dart';

class RegisterContent extends StatelessWidget {
  final bool isLoading;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final InputDecoration Function({required String hintText, Widget? suffixIcon})
  fieldDecoration;
  final VoidCallback onSubmit;
  final VoidCallback onOpenLogin;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  const RegisterContent({
    super.key,
    required this.isLoading,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.fieldDecoration,
    required this.onSubmit,
    required this.onOpenLogin,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(
            title: 'Crea tu cuenta',
            subtitle:
                'Hola, organiza tus empresas y colaboradores desde un solo lugar.',
          ),
          const SizedBox(height: 30),
          AuthTextField(
            controller: nameController,
            hintText: 'Nombre',
            textInputAction: TextInputAction.next,
            decoration: fieldDecoration(hintText: 'Nombre'),
          ),
          const SizedBox(height: 12),
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
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.password],
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
          const SizedBox(height: 12),
          AuthTextField(
            controller: confirmPasswordController,
            hintText: 'Confirmar contraseña',
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: fieldDecoration(
              hintText: 'Confirmar contraseña',
              suffixIcon: IconButton(
                onPressed: onToggleConfirmPassword,
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.muted,
                ),
              ),
            ),
            validator: (value) =>
                confirmPasswordValidator(value, passwordController.text),
          ),
          const SizedBox(height: 28),
          AuthSubmitButton(
            label: 'Registrarme',
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 26),
          AuthModePrompt(
            text: '¿Ya tienes una cuenta?',
            actionLabel: 'Inicia sesión',
            isLoading: isLoading,
            onPressed: onOpenLogin,
          ),
        ],
      ),
    );
  }
}
