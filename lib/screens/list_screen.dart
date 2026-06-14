import 'package:crud_withnodejs/models/company.dart';
import 'package:crud_withnodejs/providers/auth_provider.dart';
import 'package:crud_withnodejs/providers/company_provider.dart';
import 'package:crud_withnodejs/ui/app_theme.dart';
import 'package:crud_withnodejs/ui/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCompanies());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCompanies() async {
    final companyProvider = context.read<CompanyProvider>();
    final success = await companyProvider.load();

    if (!mounted || success) return;

    _showError(
      companyProvider.errorMessage ?? 'No se pudieron cargar empresas.',
    );
  }

  Future<bool> _deleteCompany(Company company) async {
    final id = company.id;
    if (id == null) return false;

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

    if (!mounted || shouldDelete != true) return false;

    final companyProvider = context.read<CompanyProvider>();
    final success = await companyProvider.remove(id);

    if (!mounted) return false;

    if (!success) {
      _showError(
        companyProvider.errorMessage ?? 'No se pudo eliminar la empresa.',
      );
      return false;
    }

    _showMessage('Empresa eliminada.');
    return false;
  }

  Future<void> _openForm([Company? company]) async {
    final changed = await Navigator.pushNamed(
      context,
      '/form',
      arguments: company,
    );

    if (changed == true && mounted) {
      _showMessage(
        company == null ? 'Empresa creada.' : 'Empresa actualizada.',
      );
    }
  }

  Future<void> _openDetail(Company company) async {
    if (company.id == null) return;

    final changed = await Navigator.pushNamed(
      context,
      '/detail',
      arguments: company.id,
    );

    if (changed == true && mounted) {
      await _loadCompanies();
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;

    context.read<CompanyProvider>().clear();
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
    final companyProvider = context.watch<CompanyProvider>();
    final authProvider = context.watch<AuthProvider>();
    final companies = companyProvider.visibleCompanies;
    final isShowingSkeleton =
        companyProvider.isSearchLoading ||
        (companyProvider.isLoading && companyProvider.companies.isEmpty);
    final userName = authProvider.user?.name?.trim().isNotEmpty == true
        ? authProvider.user!.name!.trim()
        : authProvider.user?.email ?? 'Usuario';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadCompanies,
          color: AppColors.blue,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 108),
            children: [
              _HomeTopBar(userName: userName, onLogout: _logout),
              const SizedBox(height: 22),
              Text(
                'Empresas',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              _SearchBox(
                controller: _searchController,
                query: companyProvider.searchQuery,
                onChanged: companyProvider.setSearchQuery,
                onClear: () {
                  _searchController.clear();
                  companyProvider.setSearchQuery('');
                },
              ),
              const SizedBox(height: 14),
              if (isShowingSkeleton) ...[
                const _DirectorySummarySkeleton(),
                const SizedBox(height: 18),
                const _LoadingState(),
              ] else ...[
                _DirectorySummary(
                  total: companyProvider.companies.length,
                  visible: companies.length,
                  isSearching: companyProvider.searchQuery.isNotEmpty,
                ),
                const SizedBox(height: 18),
                if (companies.isEmpty)
                  _EmptyState(
                    isSearching: companyProvider.searchQuery.isNotEmpty,
                  )
                else
                  ...companies.expand((company) {
                    return [
                      Dismissible(
                        key: ValueKey(company.id ?? company.taxId),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (_) => _deleteCompany(company),
                        background: const _DeleteBackground(
                          alignment: Alignment.centerLeft,
                        ),
                        secondaryBackground: const _DeleteBackground(
                          alignment: Alignment.centerRight,
                        ),
                        child: _CompanyCard(
                          company: company,
                          onTap: () => _openDetail(company),
                          onEdit: () => _openForm(company),
                          onDelete: () => _deleteCompany(company),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ];
                  }),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva empresa'),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  final String userName;
  final VoidCallback onLogout;

  const _HomeTopBar({required this.userName, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Buen día', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        IconButton.filled(
          tooltip: 'Cerrar sesión',
          onPressed: onLogout,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.ink,
          ),
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBox({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o RUC',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
      ),
    );
  }
}

class _DirectorySummary extends StatelessWidget {
  final int total;
  final int visible;
  final bool isSearching;

  const _DirectorySummary({
    required this.total,
    required this.visible,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final text = isSearching
        ? '$visible ${_matchesLabel(visible)} encontradas'
        : _registeredCompaniesLabel(total);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Row(
        children: [
          Icon(
            isSearching ? Icons.manage_search_rounded : Icons.apartment_rounded,
            size: 18,
            color: AppColors.muted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Company company;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CompanyCard({
    required this.company,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final businessLine = _valueOrFallback(company.businessLine, 'Sin rubro');
    final address = company.address?.trim();

    return Opacity(
      opacity: company.isActive ? 1 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: company.isActive ? AppShadows.card : const [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          businessLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _RucPill(taxId: company.taxId),
                            if (address != null && address.isNotEmpty)
                              _AddressInline(label: address),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Opciones',
                    padding: EdgeInsets.zero,
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
            ),
          ),
        ),
      ),
    );
  }
}

class _RucPill extends StatelessWidget {
  final String taxId;

  const _RucPill({required this.taxId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'RUC $taxId',
        style: const TextStyle(
          color: AppColors.ink,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AddressInline extends StatelessWidget {
  final String label;

  const _AddressInline({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 14,
            color: AppColors.muted,
          ),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 12, height: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  final Alignment alignment;

  const _DeleteBackground({required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: alignment,
      child: const Icon(Icons.delete_rounded, color: Colors.white),
    );
  }
}

class _DirectorySummarySkeleton extends StatelessWidget {
  const _DirectorySummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          children: [
            SkeletonBlock(width: 18, height: 18, radius: 6),
            SizedBox(width: 8),
            SkeletonBlock(width: 150, height: 14, radius: 8),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _CompanyCardSkeleton(),
        SizedBox(height: 14),
        _CompanyCardSkeleton(),
        SizedBox(height: 14),
        _CompanyCardSkeleton(),
        SizedBox(height: 14),
        _CompanyCardSkeleton(),
        SizedBox(height: 14),
        _CompanyCardSkeleton(),
      ],
    );
  }
}

class _CompanyCardSkeleton extends StatelessWidget {
  const _CompanyCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: const SkeletonShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBlock(width: 170, height: 18),
                  SizedBox(height: 8),
                  SkeletonBlock(width: 120, height: 14),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      SkeletonBlock(width: 86, height: 30, radius: 14),
                      SizedBox(width: 8),
                      SkeletonBlock(width: 120, height: 30, radius: 14),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            SkeletonBlock(width: 38, height: 38, radius: 19),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearching;

  const _EmptyState({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  isSearching
                      ? Icons.manage_search_rounded
                      : Icons.business_outlined,
                  color: AppColors.blue,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isSearching ? 'Sin resultados' : 'Aún no hay empresas',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                isSearching
                    ? 'Prueba con otro nombre o RUC para encontrar coincidencias.'
                    : 'Crea tu primera empresa y empieza a organizar el directorio.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _valueOrFallback(String? value, String fallback) {
  final trimmedValue = value?.trim();
  if (trimmedValue == null || trimmedValue.isEmpty) return fallback;

  return trimmedValue;
}

String _matchesLabel(int count) =>
    count == 1 ? 'coincidencia' : 'coincidencias';

String _registeredCompaniesLabel(int count) {
  return count == 1 ? '1 empresa registrada' : '$count empresas registradas';
}
