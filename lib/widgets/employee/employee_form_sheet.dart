import 'package:flutter/material.dart';

import 'package:crud_withnodejs/controllers/employee_form_controller.dart';
import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/models/employee.dart';
import 'package:crud_withnodejs/utils/validators.dart';
import 'package:crud_withnodejs/widgets/app_field_label.dart';
import 'package:crud_withnodejs/widgets/app_text_form_field.dart';

typedef EmployeeFormSubmitCallback =
    Future<void> Function(EmployeeFormController controller);

class EmployeeFormSheetHost extends StatefulWidget {
  final Employee? employee;
  final EmployeeFormSubmitCallback onSubmit;

  const EmployeeFormSheetHost({
    super.key,
    required this.employee,
    required this.onSubmit,
  });

  @override
  State<EmployeeFormSheetHost> createState() => _EmployeeFormSheetHostState();
}

class _EmployeeFormSheetHostState extends State<EmployeeFormSheetHost> {
  late final EmployeeFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EmployeeFormController(widget.employee);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EmployeeFormSheet(
      controller: _controller,
      onSubmit: () => widget.onSubmit(_controller),
    );
  }
}

class EmployeeFormSheet extends StatelessWidget {
  final EmployeeFormController controller;
  final VoidCallback onSubmit;

  const EmployeeFormSheet({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  controller.isEditing ? 'Editar empleado' : 'Nuevo empleado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  controller.isEditing
                      ? 'Actualiza los datos del integrante.'
                      : 'Añade datos básicos del integrante.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                AppFieldLabel('Nombre completo'),
                AppTextFormField(
                  controller: controller.fullNameController,
                  hint: 'Nombre y apellido',
                  icon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) => requiredTextValidator(
                    value,
                    'El nombre completo es obligatorio.',
                  ),
                ),
                const SizedBox(height: 14),
                AppFieldLabel('Documento'),
                AppTextFormField(
                  controller: controller.documentController,
                  hint: 'DNI, CE u otro',
                  icon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppFieldLabel('Cargo'),
                AppTextFormField(
                  controller: controller.positionController,
                  hint: 'Puesto o responsabilidad',
                  icon: Icons.work_outline_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppFieldLabel('Correo'),
                AppTextFormField(
                  controller: controller.emailController,
                  hint: 'correo@empresa.com',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppFieldLabel('Teléfono'),
                AppTextFormField(
                  controller: controller.phoneController,
                  hint: 'Número de contacto',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => onSubmit(),
                ),
                const SizedBox(height: 18),
                ValueListenableBuilder<bool>(
                  valueListenable: controller.isSaving,
                  builder: (context, isSaving, child) {
                    return FilledButton.icon(
                      onPressed: isSaving ? null : onSubmit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        backgroundColor: AppColors.blue,
                      ),
                      icon: isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                        controller.isEditing
                            ? 'Guardar cambios'
                            : 'Guardar empleado',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
