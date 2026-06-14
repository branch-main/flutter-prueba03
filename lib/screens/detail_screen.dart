import 'package:crud_withnodejs/models/company.dart';
import 'package:crud_withnodejs/models/employee.dart';
import 'package:crud_withnodejs/providers/company_provider.dart';
import 'package:crud_withnodejs/services/api_services.dart';
import 'package:crud_withnodejs/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int? _companyId;
  Company? _company;
  bool _loadedArguments = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadedArguments) return;

    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is int) {
      _companyId = arguments;
    } else if (arguments is Company) {
      _companyId = arguments.id;
      _company = arguments;
    }

    _loadedArguments = true;
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    final companyId = _companyId;
    if (companyId == null) {
      setState(() => _errorMessage = 'Empresa no encontrada.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final company = await ApiService.getCompany(companyId);
      if (!mounted) return;

      setState(() => _company = company);
    } catch (error) {
      if (!mounted) return;

      setState(() => _errorMessage = error.toString());
      _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editCompany() async {
    final company = _company;
    if (company == null) return;

    final changed = await Navigator.pushNamed(
      context,
      '/form',
      arguments: company,
    );

    if (changed == true && mounted) {
      _showMessage('Empresa actualizada.');
      await _loadCompany();
    }
  }

  Future<void> _deleteCompany() async {
    final company = _company;
    final companyId = company?.id;
    if (company == null || companyId == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmación de eliminación'),
        content: Text('¿Estás seguro que deseas eliminar "${company.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (!mounted || shouldDelete != true) return;

    final companyProvider = context.read<CompanyProvider>();
    final success = await companyProvider.remove(companyId);

    if (!mounted) return;

    if (!success) {
      _showError(
        companyProvider.errorMessage ?? 'No se pudo eliminar la empresa.',
      );
      return;
    }

    Navigator.pop(context, true);
  }

  Future<void> _createEmployee() async {
    final companyId = _company?.id;
    if (companyId == null) return;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EmployeeFormSheet(companyId: companyId),
    );

    if (created == true && mounted) {
      _showMessage('Empleado registrado.');
      await _loadCompany();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    final company = _company;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _isLoading ? null : _loadCompany,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading && company == null) {
            return const _DetailLoading();
          }

          if (_errorMessage != null && company == null) {
            return _ErrorState(message: _errorMessage!, onRetry: _loadCompany);
          }

          if (company == null) {
            return const _NotFoundState();
          }

          return RefreshIndicator(
            onRefresh: _loadCompany,
            color: AppColors.blue,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
              children: [
                _CompanySummary(
                  company: company,
                  onEdit: _editCompany,
                  onDelete: _deleteCompany,
                ),
                const SizedBox(height: 16),
                _InfoSection(company: company),
                const SizedBox(height: 16),
                _EmployeesSection(employees: company.employees),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _company == null ? null : _createEmployee,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Empleado'),
      ),
    );
  }
}

class _CompanySummary extends StatelessWidget {
  final Company company;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CompanySummary({
    required this.company,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  _initials(company.name),
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SummaryPill(
                          icon: Icons.badge_outlined,
                          label: 'RUC ${company.taxId}',
                        ),
                        const _SummaryPill(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Activa',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('Eliminar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SummaryPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.muted),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final Company company;

  const _InfoSection({required this.company});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Información',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _DetailItem(
            icon: Icons.location_on_outlined,
            label: 'Dirección',
            value: company.address ?? 'Sin dirección',
          ),
          const SizedBox(height: 10),
          _DetailItem(
            icon: Icons.storefront_rounded,
            label: 'Rubro',
            value: company.businessLine ?? 'Sin rubro',
          ),
        ],
      ),
    );
  }
}

class _EmployeesSection extends StatelessWidget {
  final List<Employee> employees;

  const _EmployeesSection({required this.employees});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Equipo',
      icon: Icons.groups_rounded,
      trailing: _CountPill(count: employees.length),
      child: employees.isEmpty
          ? const _EmptyEmployees()
          : Column(
              children: employees
                  .map(
                    (employee) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _EmployeeCard(employee: employee),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;

  const _EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    final details = [
      employee.documentNumber == null ? null : 'Doc ${employee.documentNumber}',
      employee.email,
      employee.phone,
    ].whereType<String>().toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.blue.withValues(alpha: 0.1),
            child: Text(
              _initials(employee.fullName),
              style: const TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fullName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  employee.position ?? 'Sin cargo asignado',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: details
                        .map((detail) => _SmallInfo(label: detail))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallInfo extends StatelessWidget {
  final String label;

  const _SmallInfo({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int count;

  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: AppColors.blue,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyEmployees extends StatelessWidget {
  const _EmptyEmployees();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_add_alt_1_rounded, color: AppColors.blue),
          const SizedBox(height: 10),
          Text(
            'No hay empleados registrados.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Usa el botón inferior para agregar el primer integrante.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.blue),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 56),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Empresa no encontrada.'));
  }
}

class _EmployeeFormSheet extends StatefulWidget {
  final int companyId;

  const _EmployeeFormSheet({required this.companyId});

  @override
  State<_EmployeeFormSheet> createState() => _EmployeeFormSheetState();
}

class _EmployeeFormSheetState extends State<_EmployeeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _documentController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _documentController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await ApiService.createEmployee(
        companyId: widget.companyId,
        employee: Employee(
          fullName: _fullNameController.text.trim(),
          documentNumber: _optionalText(_documentController.text),
          position: _optionalText(_positionController.text),
          email: _optionalText(_emailController.text),
          phone: _optionalText(_phoneController.text),
        ),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _optionalText(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

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
          key: _formKey,
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
                  'Nuevo empleado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Añade datos básicos del integrante.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                _FieldLabel('Nombre completo'),
                _SheetField(
                  controller: _fullNameController,
                  hint: 'Nombre y apellido',
                  icon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'El nombre completo es obligatorio.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _FieldLabel('Documento'),
                _SheetField(
                  controller: _documentController,
                  hint: 'DNI, CE u otro',
                  icon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                _FieldLabel('Cargo'),
                _SheetField(
                  controller: _positionController,
                  hint: 'Puesto o responsabilidad',
                  icon: Icons.work_outline_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                _FieldLabel('Correo'),
                _SheetField(
                  controller: _emailController,
                  hint: 'correo@empresa.com',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                _FieldLabel('Teléfono'),
                _SheetField(
                  controller: _phoneController,
                  hint: 'Número de contacto',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: AppColors.blue,
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: const Text('Guardar empleado'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  const _SheetField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
      validator: validator,
    );
  }
}

String _initials(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.isEmpty) return 'E';

  final first = parts.first[0];
  final second = parts.length > 1
      ? parts[1][0]
      : parts.first.length > 1
      ? parts.first[1]
      : '';

  return '$first$second'.toUpperCase();
}
