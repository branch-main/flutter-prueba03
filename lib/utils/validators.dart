String? requiredTextValidator(String? value, String message) {
  return (value ?? '').trim().isEmpty ? message : null;
}

String? emailValidator(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Ingresa tu correo.';
  if (!email.contains('@')) return 'Ingresa un correo válido.';

  return null;
}

String? passwordValidator(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Ingresa tu contraseña.';
  if (password.length < 6) return 'Debe tener al menos 6 caracteres.';

  return null;
}

String? confirmPasswordValidator(String? value, String password) {
  if ((value ?? '').isEmpty) return 'Confirma tu contraseña.';
  if (value != password) return 'Las contraseñas no coinciden.';

  return null;
}
