import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crud_withnodejs/controllers/company_detail_controller.dart';
import 'package:crud_withnodejs/controllers/employee_form_controller.dart';
import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/models/employee.dart';
import 'package:crud_withnodejs/providers/company_provider.dart';
import 'package:crud_withnodejs/utils/dialog_utils.dart';
import 'package:crud_withnodejs/widgets/company/company_info_section.dart';
import 'package:crud_withnodejs/widgets/company/company_summary.dart';
import 'package:crud_withnodejs/widgets/company/detail_error_state.dart';
import 'package:crud_withnodejs/widgets/company/detail_loading.dart';
import 'package:crud_withnodejs/widgets/company/detail_not_found_state.dart';
import 'package:crud_withnodejs/widgets/employee/employee_form_sheet.dart';
import 'package:crud_withnodejs/widgets/employee/employees_section.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _controller = CompanyDetailController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final shouldLoad = _controller.loadArguments(
      ModalRoute.of(context)?.settings.arguments,
    );

    if (!shouldLoad) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadCompany();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCompany() async {
    final errorMessage = await _controller.load(
      context.read<CompanyProvider>(),
    );
    if (!mounted || errorMessage == null) return;

    showAppError(context, errorMessage);
  }

  Future<void> _editCompany() async {
    final company = _controller.company;
    if (company == null) return;

    final changed = await Navigator.pushNamed(
      context,
      '/form',
      arguments: company,
    );

    if (changed == true && mounted) {
      showAppMessage(context, 'Empresa actualizada.');
      await _loadCompany();
    }
  }

  Future<void> _deleteCompany() async {
    final company = _controller.company;
    if (company?.id == null) return;

    final shouldDelete = await confirmDestructiveAction(
      context,
      title: 'Confirmación de eliminación',
      message: '¿Estás seguro que deseas eliminar "${company!.name}"?',
    );

    if (!mounted || !shouldDelete) return;

    final errorMessage = await _controller.deleteCompany(
      context.read<CompanyProvider>(),
    );

    if (!mounted) return;

    if (errorMessage != null) {
      showAppError(context, errorMessage);
      return;
    }

    Navigator.pop(context, true);
  }

  Future<void> _toggleCompanyStatus() async {
    final message = await _controller.toggleCompanyStatus(
      context.read<CompanyProvider>(),
    );

    if (!mounted) return;

    if (message == null) {
      final errorMessage = _controller.errorMessage;
      if (errorMessage != null) showAppError(context, errorMessage);
      return;
    }

    showAppMessage(context, message);
  }

  Future<void> _openEmployeeForm([Employee? employee]) async {
    final company = _controller.company;
    if (company?.id == null) return;

    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => EmployeeFormSheetHost(
        employee: employee,
        onSubmit: (formController) => _submitEmployeeForm(
          sheetContext: sheetContext,
          currentEmployee: employee,
          formController: formController,
        ),
      ),
    );

    if (changed == true && mounted) {
      showAppMessage(
        context,
        employee == null ? 'Empleado registrado.' : 'Empleado actualizado.',
      );
    }
  }

  Future<void> _submitEmployeeForm({
    required BuildContext sheetContext,
    required Employee? currentEmployee,
    required EmployeeFormController formController,
  }) async {
    if (!formController.validate() || formController.isSaving.value) return;

    formController.isSaving.value = true;

    try {
      final errorMessage = await _controller.saveEmployee(
        provider: context.read<CompanyProvider>(),
        currentEmployee: currentEmployee,
        draft: formController.toEmployee(),
      );

      if (!mounted || !sheetContext.mounted) return;

      if (errorMessage != null) {
        showAppError(sheetContext, errorMessage);
        return;
      }

      Navigator.pop(sheetContext, true);
    } finally {
      if (!formController.isDisposed) {
        formController.isSaving.value = false;
      }
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final company = _controller.company;
    if (company?.id == null || employee.id == null) return;

    final shouldDelete = await confirmDestructiveAction(
      context,
      title: 'Eliminar empleado',
      message: '¿Estás seguro que deseas eliminar a "${employee.fullName}"?',
    );

    if (!mounted || !shouldDelete) return;

    final errorMessage = await _controller.deleteEmployee(
      provider: context.read<CompanyProvider>(),
      employee: employee,
    );

    if (!mounted) return;

    if (errorMessage != null) {
      showAppError(context, errorMessage);
      return;
    }

    showAppMessage(context, 'Empleado eliminado.');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final company = _controller.company;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              company?.name ?? 'Empresa',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  tooltip: 'Actualizar',
                  onPressed: _controller.isLoading ? null : _loadCompany,
                  icon: _controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (_controller.isLoading && company == null) {
                return const DetailLoading();
              }

              if (_controller.errorMessage != null && company == null) {
                return DetailErrorState(
                  message: _controller.errorMessage!,
                  onRetry: _loadCompany,
                );
              }

              if (company == null) {
                return const DetailNotFoundState();
              }

              return RefreshIndicator(
                onRefresh: _loadCompany,
                color: AppColors.blue,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
                  children: [
                    CompanySummary(
                      company: company,
                      isUpdatingStatus: _controller.isUpdatingStatus,
                      onEdit: _editCompany,
                      onDelete: _deleteCompany,
                      onToggleStatus: _toggleCompanyStatus,
                    ),
                    const SizedBox(height: 16),
                    CompanyInfoSection(company: company),
                    const SizedBox(height: 16),
                    EmployeesSection(
                      employees: company.employees,
                      onEdit: _openEmployeeForm,
                      onDelete: _deleteEmployee,
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: company == null ? null : _openEmployeeForm,
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Empleado'),
          ),
        );
      },
    );
  }
}
