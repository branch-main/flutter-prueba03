import 'package:flutter/material.dart';

import 'package:crud_withnodejs/models/employee.dart';
import 'package:crud_withnodejs/utils/string_utils.dart';

class EmployeeFormController {
  final Employee? employee;
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final documentController = TextEditingController();
  final positionController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final isSaving = ValueNotifier(false);
  bool _isDisposed = false;

  EmployeeFormController(this.employee) {
    final employee = this.employee;
    if (employee == null) return;

    fullNameController.text = employee.fullName;
    documentController.text = employee.documentNumber ?? '';
    positionController.text = employee.position ?? '';
    emailController.text = employee.email ?? '';
    phoneController.text = employee.phone ?? '';
  }

  bool get isEditing => employee?.id != null;
  bool get isDisposed => _isDisposed;

  bool validate() => formKey.currentState?.validate() ?? false;

  Employee toEmployee() {
    return Employee(
      fullName: fullNameController.text.trim(),
      documentNumber: optionalText(documentController.text),
      position: optionalText(positionController.text),
      email: optionalText(emailController.text),
      phone: optionalText(phoneController.text),
      isActive: employee?.isActive ?? true,
    );
  }

  void dispose() {
    _isDisposed = true;
    fullNameController.dispose();
    documentController.dispose();
    positionController.dispose();
    emailController.dispose();
    phoneController.dispose();
    isSaving.dispose();
  }
}
