import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crud_withnodejs/controllers/company_form_controller.dart';
import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/providers/company_provider.dart';
import 'package:crud_withnodejs/utils/dialog_utils.dart';
import 'package:crud_withnodejs/widgets/company/company_form_fields.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _controller = CompanyFormController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.loadArguments(ModalRoute.of(context)?.settings.arguments);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_controller.validate()) return;

    final company = _controller.toCompany();
    final companyProvider = context.read<CompanyProvider>();
    final success = _controller.isEditing
        ? await companyProvider.update(_controller.company!.id!, company)
        : await companyProvider.add(company);

    if (!mounted) return;

    if (!success) {
      showAppError(
        context,
        companyProvider.errorMessage ?? 'No se pudo guardar.',
      );
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_controller.isEditing ? 'Editar empresa' : 'Nueva empresa'),
      ),
      body: Form(
        key: _controller.formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            CompanyFormFields(
              nameController: _controller.nameController,
              taxIdController: _controller.taxIdController,
              addressController: _controller.addressController,
              businessLineController: _controller.businessLineController,
              onSubmitted: _save,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: companyProvider.isLoading ? null : _save,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: AppColors.blue,
          ),
          child: companyProvider.isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _controller.isEditing ? 'Guardar cambios' : 'Crear empresa',
                ),
        ),
      ),
    );
  }
}
