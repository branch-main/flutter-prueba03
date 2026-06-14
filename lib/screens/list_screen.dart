import 'package:crud_withnodejs/models/company.dart';
import 'package:crud_withnodejs/providers/auth_provider.dart';
import 'package:crud_withnodejs/providers/company_provider.dart';
import 'package:crud_withnodejs/ui/app_theme.dart';
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
              const SizedBox(height: 18),
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
              _StatsRow(
                total: companyProvider.companies.length,
                visible: companies.length,
                isSearching: companyProvider.searchQuery.isNotEmpty,
              ),
              const SizedBox(height: 20),
              if (companyProvider.isLoading &&
                  companyProvider.companies.isEmpty)
                const _LoadingState()
              else if (companies.isEmpty)
                _EmptyState(isSearching: companyProvider.searchQuery.isNotEmpty)
              else
                ...companies.indexed.expand((entry) {
                  final index = entry.$1;
                  final company = entry.$2;

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
                        color: _cardColors[index % _cardColors.length],
                        onTap: () => _openDetail(company),
                        onEdit: () => _openForm(company),
                        onDelete: () => _deleteCompany(company),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ];
                }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva empresa'),
      ),
    );
  }
}

const _cardColors = [
  AppColors.blue,
  AppColors.cyan,
  AppColors.mint,
  AppColors.amber,
];

class _HomeTopBar extends StatelessWidget {
  final String userName;
  final VoidCallback onLogout;

  const _HomeTopBar({required this.userName, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppGradients.accent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _initials(userName),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 14),
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

class _StatsRow extends StatelessWidget {
  final int total;
  final int visible;
  final bool isSearching;

  const _StatsRow({
    required this.total,
    required this.visible,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: Icons.apartment_rounded,
            label: '$total empresas',
            selected: !isSearching,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            icon: Icons.manage_search_rounded,
            label: isSearching ? '$visible resultados' : 'Todo visible',
            selected: isSearching,
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: selected ? Colors.white : AppColors.muted,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Company company;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CompanyCard({
    required this.company,
    required this.color,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _initials(company.name),
                        style: TextStyle(
                          color: color,
                          fontSize: 18,
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _RucPill(taxId: company.taxId),
                              const SizedBox(width: 8),
                              const _StatusPill(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Opciones',
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
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.storefront_rounded,
                      label: company.businessLine ?? 'Sin rubro',
                    ),
                    _InfoChip(
                      icon: Icons.location_on_outlined,
                      label: company.address ?? 'Sin dirección',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_outward_rounded),
                  label: const Text('Ver detalle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Activo',
        style: TextStyle(
          color: AppColors.mint,
          fontSize: 12,
          fontWeight: FontWeight.w900,
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
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.muted),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 250,
      child: Center(child: CircularProgressIndicator(color: AppColors.blue)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearching;

  const _EmptyState({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
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
