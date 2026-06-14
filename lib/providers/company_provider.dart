import 'dart:async';

import 'package:flutter/material.dart';

import 'package:crud_withnodejs/models/company.dart';
import 'package:crud_withnodejs/models/employee.dart';
import 'package:crud_withnodejs/services/api_services.dart';

class CompanyProvider with ChangeNotifier {
  static const _searchDebounceDuration = Duration(milliseconds: 300);

  List<Company> _companies = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSearchLoading = false;
  String? _errorMessage;
  Timer? _searchDebounce;
  int _companiesRequestId = 0;

  List<Company> get companies => _companies;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSearchLoading => _isSearchLoading;
  String? get errorMessage => _errorMessage;

  String get _trimmedSearchQuery => _searchQuery.trim();

  void setSearchQuery(String value) {
    _searchQuery = value;
    _searchDebounce?.cancel();

    final requestId = _nextCompaniesRequestId();
    final search = _trimmedSearchQuery;
    _errorMessage = null;
    _isLoading = false;
    _isSearchLoading = true;
    notifyListeners();

    _searchDebounce = Timer(_searchDebounceDuration, () {
      unawaited(
        _fetchCompanies(
          search: search,
          requestId: requestId,
          showSearchLoading: true,
        ),
      );
    });
  }

  void clear() {
    _searchDebounce?.cancel();
    _nextCompaniesRequestId();
    _companies = [];
    _searchQuery = '';
    _errorMessage = null;
    _isLoading = false;
    _isSearchLoading = false;
    notifyListeners();
  }

  Future<bool> load() async {
    _searchDebounce?.cancel();
    return _fetchCompanies(
      search: _trimmedSearchQuery,
      requestId: _nextCompaniesRequestId(),
      showSearchLoading: false,
    );
  }

  Future<Company?> getCompany(int id) async {
    _setError(null);

    try {
      return await ApiService.getCompany(id);
    } catch (error) {
      _setError(error.toString());
      return null;
    }
  }

  Future<bool> add(Company company) async {
    _beginMutation();
    final search = _trimmedSearchQuery;

    try {
      final createdCompany = await ApiService.createCompany(company);
      _applyCreatedCompany(createdCompany, search);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> update(int id, Company company) async {
    _beginMutation();
    final search = _trimmedSearchQuery;

    try {
      final updatedCompany = await ApiService.updateCompany(id, company);
      _applyUpdatedCompany(updatedCompany, search);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> remove(int id) async {
    _beginMutation();

    try {
      await ApiService.deleteCompany(id);
      _companies.removeWhere((company) => company.id == id);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Employee?> createEmployee({
    required int companyId,
    required Employee employee,
  }) async {
    _setError(null);

    try {
      return await ApiService.createEmployee(
        companyId: companyId,
        employee: employee,
      );
    } catch (error) {
      _setError(error.toString());
      return null;
    }
  }

  Future<Employee?> updateEmployee({
    required int companyId,
    required int employeeId,
    required Employee employee,
  }) async {
    _setError(null);

    try {
      return await ApiService.updateEmployee(
        companyId: companyId,
        employeeId: employeeId,
        employee: employee,
      );
    } catch (error) {
      _setError(error.toString());
      return null;
    }
  }

  Future<bool> removeEmployee({
    required int companyId,
    required int employeeId,
  }) async {
    _setError(null);

    try {
      await ApiService.deleteEmployee(
        companyId: companyId,
        employeeId: employeeId,
      );
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    }
  }

  Future<bool> _fetchCompanies({
    required String search,
    required int requestId,
    required bool showSearchLoading,
  }) async {
    _isLoading = !showSearchLoading;
    _isSearchLoading = showSearchLoading;
    _errorMessage = null;
    notifyListeners();

    try {
      final companies = await ApiService.getCompanies(search: search);
      if (!_isCurrentCompaniesRequest(requestId)) return false;

      _companies = companies;
      return true;
    } catch (error) {
      if (!_isCurrentCompaniesRequest(requestId)) return false;

      _errorMessage = error.toString();
      return false;
    } finally {
      if (_isCurrentCompaniesRequest(requestId)) {
        _isLoading = false;
        _isSearchLoading = false;
        notifyListeners();
      }
    }
  }

  void _applyCreatedCompany(Company company, String search) {
    if (search.isNotEmpty && !_matchesSearch(company, search)) return;

    _companies.removeWhere((item) => _hasSameId(item, company));
    _companies.insert(0, company);
  }

  void _applyUpdatedCompany(Company company, String search) {
    final index = _companies.indexWhere((item) => _hasSameId(item, company));
    final shouldShow = search.isEmpty || _matchesSearch(company, search);

    if (!shouldShow) {
      if (index != -1) _companies.removeAt(index);
      return;
    }

    if (index == -1) {
      if (search.isNotEmpty) _companies.insert(0, company);
      return;
    }

    _companies[index] = company;
  }

  bool _matchesSearch(Company company, String search) {
    final normalizedSearch = search.toLowerCase();
    return company.name.toLowerCase().contains(normalizedSearch) ||
        company.taxId.toLowerCase().contains(normalizedSearch);
  }

  bool _hasSameId(Company first, Company second) {
    return first.id != null && first.id == second.id;
  }

  void _beginMutation() {
    _searchDebounce?.cancel();
    _nextCompaniesRequestId();
    _isLoading = true;
    _isSearchLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  int _nextCompaniesRequestId() => ++_companiesRequestId;

  bool _isCurrentCompaniesRequest(int requestId) {
    return requestId == _companiesRequestId;
  }

  void _setLoading(bool loading) {
    if (_isLoading == loading) return;

    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    if (_errorMessage == error) return;

    _errorMessage = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _nextCompaniesRequestId();
    super.dispose();
  }
}
