import 'package:crud_withnodejs/models/company.dart';
import 'package:crud_withnodejs/models/employee.dart';
import 'package:crud_withnodejs/providers/company_provider.dart';
import 'package:crud_withnodejs/services/api_services.dart';
import 'package:crud_withnodejs/ui/app_theme.dart';
import 'package:crud_withnodejs/ui/skeleton.dart';
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
  bool _isUpdatingStatus = false;
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

  Future<void> _toggleCompanyStatus() async {
    final company = _company;
    final companyId = company?.id;
    if (company == null || companyId == null || _isUpdatingStatus) return;

    final nextIsActive = !company.isActive;

    setState(() => _isUpdatingStatus = true);

    final companyProvider = context.read<CompanyProvider>();
    final success = await companyProvider.update(
      companyId,
      Company(
        name: company.name,
        taxId: company.taxId,
        address: company.address,
        businessLine: company.businessLine,
        isActive: nextIsActive,
      ),
    );

    if (!mounted) return;

    if (!success) {
      setState(() => _isUpdatingStatus = false);
      _showError(
        companyProvider.errorMessage ?? 'No se pudo actualizar el estado.',
      );
      return;
    }

    _showMessage(nextIsActive ? 'Empresa activada.' : 'Empresa desactivada.');
    await _loadCompany();

    if (mounted) setState(() => _isUpdatingStatus = false);
  }

  Future<void> _openEmployeeForm([Employee? employee]) async {
    final companyId = _company?.id;
    if (companyId == null) return;

    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _EmployeeFormSheet(companyId: companyId, employee: employee),
    );

    if (changed == true && mounted) {
      _showMessage(
        employee == null ? 'Empleado registrado.' : 'Empleado actualizado.',
      );
      await _loadCompany();
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final companyId = _company?.id;
    final employeeId = employee.id;
    if (companyId == null || employeeId == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar empleado'),
        content: Text(
          '¿Estás seguro que deseas eliminar a "${employee.fullName}"?',
        ),
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

    try {
      await ApiService.deleteEmployee(
        companyId: companyId,
        employeeId: employeeId,
      );

      if (!mounted) return;

      _showMessage('Empleado eliminado.');
      await _loadCompany();
    } catch (error) {
      if (!mounted) return;
      _showError(error.toString());
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
              onPressed: _isLoading ? null : _loadCompany,
              icon: _isLoading
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
                  isUpdatingStatus: _isUpdatingStatus,
                  onEdit: _editCompany,
                  onDelete: _deleteCompany,
                  onToggleStatus: _toggleCompanyStatus,
                ),
                const SizedBox(height: 16),
                _InfoSection(company: company),
                const SizedBox(height: 16),
                _EmployeesSection(
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
        onPressed: _company == null ? null : _openEmployeeForm,
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Empleado'),
      ),
    );
  }
}

class _CompanySummary extends StatelessWidget {
  final Company company;
  final bool isUpdatingStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _CompanySummary({
    required this.company,
    required this.isUpdatingStatus,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                size: 18,
                color: AppColors.muted,
              ),
              const SizedBox(width: 8),
              Text(
                'RUC ${company.taxId}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StatusToggle(
            isActive: company.isActive,
            isLoading: isUpdatingStatus,
            onChanged: onToggleStatus,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Editar'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_rounded),
                    label: const Text('Eliminar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                    ),
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

class _StatusToggle extends StatelessWidget {
  final bool isActive;
  final bool isLoading;
  final VoidCallback onChanged;

  const _StatusToggle({
    required this.isActive,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isActive
                      ? 'Activa en el directorio'
                      : 'Inactiva en el directorio',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch.adaptive(
              value: isActive,
              activeThumbColor: AppColors.blue,
              onChanged: (_) => onChanged(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailItem(
            icon: Icons.location_on_outlined,
            label: 'Dirección',
            value: company.address ?? 'Sin dirección',
          ),
          const Divider(height: 22, color: AppColors.line),
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
  final ValueChanged<Employee> onEdit;
  final ValueChanged<Employee> onDelete;

  const _EmployeesSection({
    required this.employees,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Equipo (${employees.length})',
      child: employees.isEmpty
          ? const _EmptyEmployees()
          : Column(
              children: [
                for (final entry in employees.indexed) ...[
                  _EmployeeCard(
                    employee: entry.$2,
                    onEdit: () => onEdit(entry.$2),
                    onDelete: () => onDelete(entry.$2),
                  ),
                  if (entry.$1 != employees.length - 1)
                    const Divider(height: 26, color: AppColors.line),
                ],
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: child),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 24, color: AppColors.blue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmployeeCard({
    required this.employee,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasInlineDetails =
        employee.documentNumber != null || employee.email != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.blue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      employee.position ?? 'Sin cargo asignado',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opciones de empleado',
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ],
          ),
          if (hasInlineDetails) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 10,
              children: [
                if (employee.documentNumber != null)
                  _EmployeeMeta(
                    icon: Icons.badge_outlined,
                    label: employee.documentNumber!,
                  ),
                if (employee.email != null)
                  _EmployeeMeta(
                    icon: Icons.alternate_email_rounded,
                    label: employee.email!,
                  ),
              ],
            ),
          ],
          if (employee.phone != null) ...[
            SizedBox(height: hasInlineDetails ? 10 : 12),
            _EmployeeMeta(icon: Icons.phone_outlined, label: employee.phone!),
          ],
        ],
      ),
    );
  }
}

class _EmployeeMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EmployeeMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.muted),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _EmptyEmployees extends StatelessWidget {
  const _EmptyEmployees();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No hay empleados registrados.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Usa el botón inferior para agregar el primer integrante.',
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
      children: const [
        _DetailSummarySkeleton(),
        SizedBox(height: 16),
        _DetailInfoSkeleton(),
        SizedBox(height: 16),
        _DetailEmployeesSkeleton(),
      ],
    );
  }
}

class _DetailSummarySkeleton extends StatelessWidget {
  const _DetailSummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.card,
      ),
      child: SkeletonShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBlock(width: 190, height: 22),
            const SizedBox(height: 12),
            const Row(
              children: [
                SkeletonBlock(width: 18, height: 18, radius: 6),
                SizedBox(width: 8),
                SkeletonBlock(width: 120, height: 15),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBlock(width: 60, height: 14),
                        SizedBox(height: 6),
                        SkeletonBlock(width: 150, height: 14),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  SkeletonBlock(width: 48, height: 28, radius: 14),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(child: SkeletonBlock(height: 48, radius: 16)),
                SizedBox(width: 10),
                Expanded(child: SkeletonBlock(height: 48, radius: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailInfoSkeleton extends StatelessWidget {
  const _DetailInfoSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBlock(width: 125, height: 24),
            SizedBox(height: 18),
            _DetailItemSkeleton(),
            SizedBox(height: 18),
            _DetailItemSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _DetailItemSkeleton extends StatelessWidget {
  const _DetailItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(width: 24, height: 24, radius: 8),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBlock(width: 90, height: 13),
              SizedBox(height: 8),
              SkeletonBlock(width: 180, height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailEmployeesSkeleton extends StatelessWidget {
  const _DetailEmployeesSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBlock(width: 110, height: 24),
            SizedBox(height: 18),
            _EmployeeCardSkeleton(),
            SizedBox(height: 20),
            _EmployeeCardSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _EmployeeCardSkeleton extends StatelessWidget {
  const _EmployeeCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBlock(width: 44, height: 44, radius: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(width: 170, height: 17),
                  SizedBox(height: 8),
                  SkeletonBlock(width: 120, height: 14),
                ],
              ),
            ),
            SizedBox(width: 12),
            SkeletonBlock(width: 38, height: 38, radius: 19),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            SkeletonBlock(width: 105, height: 16),
            SizedBox(width: 14),
            SkeletonBlock(width: 150, height: 16),
          ],
        ),
      ],
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
  final Employee? employee;

  const _EmployeeFormSheet({required this.companyId, this.employee});

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

  bool get _isEditing => widget.employee?.id != null;

  @override
  void initState() {
    super.initState();

    final employee = widget.employee;
    if (employee == null) return;

    _fullNameController.text = employee.fullName;
    _documentController.text = employee.documentNumber ?? '';
    _positionController.text = employee.position ?? '';
    _emailController.text = employee.email ?? '';
    _phoneController.text = employee.phone ?? '';
  }

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
      final employee = Employee(
        fullName: _fullNameController.text.trim(),
        documentNumber: _optionalText(_documentController.text),
        position: _optionalText(_positionController.text),
        email: _optionalText(_emailController.text),
        phone: _optionalText(_phoneController.text),
        isActive: widget.employee?.isActive ?? true,
      );

      if (_isEditing) {
        await ApiService.updateEmployee(
          companyId: widget.companyId,
          employeeId: widget.employee!.id!,
          employee: employee,
        );
      } else {
        await ApiService.createEmployee(
          companyId: widget.companyId,
          employee: employee,
        );
      }

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
                  _isEditing ? 'Editar empleado' : 'Nuevo empleado',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditing
                      ? 'Actualiza los datos del integrante.'
                      : 'Añade datos básicos del integrante.',
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
                  label: Text(
                    _isEditing ? 'Guardar cambios' : 'Guardar empleado',
                  ),
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
          fontWeight: FontWeight.w500,
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
