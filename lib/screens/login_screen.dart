import 'package:crud_withnodejs/providers/auth_provider.dart';
import 'package:crud_withnodejs/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = _isRegisterMode
        ? await authProvider.register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim().isEmpty
                ? null
                : _nameController.text.trim(),
          )
        : await authProvider.login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

    if (!mounted || success) return;

    _showError(authProvider.errorMessage ?? 'No se pudo iniciar sesión.');
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _confirmPasswordController.clear();
      _formKey.currentState?.reset();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
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
              child: _AuthContent(
                isRegisterMode: _isRegisterMode,
                isLoading: authProvider.isLoading,
                formKey: _formKey,
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                obscurePassword: _obscurePassword,
                obscureConfirmPassword: _obscureConfirmPassword,
                fieldDecoration: _fieldDecoration,
                onSubmit: _submit,
                onToggleMode: _toggleMode,
                onTogglePassword: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onToggleConfirmPassword: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthContent extends StatelessWidget {
  final bool isRegisterMode;
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
  final VoidCallback onToggleMode;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  const _AuthContent({
    required this.isRegisterMode,
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
    required this.onToggleMode,
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
          const _BrandMark(),
          const SizedBox(height: 46),
          Text(
            isRegisterMode ? 'Crea tu cuenta' : 'Inicia sesión',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 30,
              height: 1.05,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isRegisterMode
                ? 'Hola, organiza tus empresas y colaboradores desde un solo lugar.'
                : 'Bienvenido de vuelta. Continúa administrando tu directorio empresarial.',
            style: const TextStyle(
              color: Color(0xFF20232A),
              fontSize: 16,
              height: 1.38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isRegisterMode ? 30 : 34),
          if (isRegisterMode) ...[
            _AuthTextField(
              controller: nameController,
              hintText: 'Nombre',
              textInputAction: TextInputAction.next,
              decoration: fieldDecoration(hintText: 'Nombre'),
            ),
            const SizedBox(height: 12),
          ],
          _AuthTextField(
            controller: emailController,
            hintText: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            decoration: fieldDecoration(hintText: 'Correo'),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Ingresa tu correo.';
              if (!email.contains('@')) return 'Ingresa un correo válido.';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _AuthTextField(
            controller: passwordController,
            hintText: 'Contraseña',
            obscureText: obscurePassword,
            textInputAction: isRegisterMode
                ? TextInputAction.next
                : TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) {
              if (!isRegisterMode) onSubmit();
            },
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
            validator: (value) {
              final password = value ?? '';
              if (password.isEmpty) return 'Ingresa tu contraseña.';
              if (password.length < 6) {
                return 'Debe tener al menos 6 caracteres.';
              }
              return null;
            },
          ),
          if (isRegisterMode) ...[
            const SizedBox(height: 12),
            _AuthTextField(
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
              validator: (value) {
                if ((value ?? '').isEmpty) {
                  return 'Confirma tu contraseña.';
                }
                if (value != passwordController.text) {
                  return 'Las contraseñas no coinciden.';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: isLoading ? null : onSubmit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(isRegisterMode ? 'Registrarme' : 'Entrar'),
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isRegisterMode
                    ? '¿Ya tienes una cuenta?'
                    : '¿No tienes cuenta?',
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                onPressed: isLoading ? null : onToggleMode,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(isRegisterMode ? 'Inicia sesión' : 'Regístrate'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        obscureText: obscureText,
        onFieldSubmitted: onFieldSubmitted,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: decoration.copyWith(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        validator: validator,
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.business_center_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }
}
