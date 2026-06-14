import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crud_withnodejs/core/app_theme.dart';
import 'package:crud_withnodejs/models/company.dart';
import 'package:crud_withnodejs/providers/auth_provider.dart';
import 'package:crud_withnodejs/providers/company_provider.dart';
import 'package:crud_withnodejs/utils/dialog_utils.dart';
import 'package:crud_withnodejs/widgets/company/company_card.dart';
import 'package:crud_withnodejs/widgets/company/company_directory_summary.dart';
import 'package:crud_withnodejs/widgets/company/company_directory_summary_skeleton.dart';
import 'package:crud_withnodejs/widgets/company/company_empty_state.dart';
import 'package:crud_withnodejs/widgets/company/company_list_loading.dart';
import 'package:crud_withnodejs/widgets/company/company_search_box.dart';
import 'package:crud_withnodejs/widgets/company/delete_background.dart';
import 'package:crud_withnodejs/widgets/company/home_top_bar.dart';

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

    showAppError(
      context,
      companyProvider.errorMessage ?? 'No se pudieron cargar empresas.',
    );
  }

  Future<bool> _deleteCompany(Company company) async {
    final id = company.id;
    if (id == null) return false;

    final shouldDelete = await confirmDestructiveAction(
      context,
      title: 'Confirmación de eliminación',
      message: '¿Estás seguro que deseas eliminar "${company.name}"?',
    );

    if (!mounted || !shouldDelete) return false;

    final companyProvider = context.read<CompanyProvider>();
    final success = await companyProvider.remove(id);

    if (!mounted) return false;

    if (!success) {
      showAppError(
        context,
        companyProvider.errorMessage ?? 'No se pudo eliminar la empresa.',
      );
      return false;
    }

    showAppMessage(context, 'Empresa eliminada.');
    return false;
  }

  Future<void> _openForm([Company? company]) async {
    final changed = await Navigator.pushNamed(
      context,
      '/form',
      arguments: company,
    );

    if (changed == true && mounted) {
      showAppMessage(
        context,
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
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final companyProvider = context.watch<CompanyProvider>();
    final authProvider = context.watch<AuthProvider>();
    final companies = companyProvider.companies;
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
              HomeTopBar(userName: userName, onLogout: _logout),
              const SizedBox(height: 22),
              Text(
                'Empresas',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              CompanySearchBox(
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
                const CompanyDirectorySummarySkeleton(),
                const SizedBox(height: 18),
                const CompanyListLoading(),
              ] else ...[
                CompanyDirectorySummary(
                  total: companyProvider.companies.length,
                  visible: companies.length,
                  isSearching: companyProvider.searchQuery.isNotEmpty,
                ),
                const SizedBox(height: 18),
                if (companies.isEmpty)
                  CompanyEmptyState(
                    isSearching: companyProvider.searchQuery.isNotEmpty,
                  )
                else
                  ...companies.expand((company) {
                    return [
                      Dismissible(
                        key: ValueKey(company.id ?? company.taxId),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => _deleteCompany(company),
                        background: const SizedBox.shrink(),
                        secondaryBackground: const DeleteBackground(
                          alignment: Alignment.centerRight,
                        ),
                        child: CompanyCard(
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
