import 'package:crud_withnodejs/models/company.dart';
import 'package:crud_withnodejs/services/api_services.dart';
import 'package:flutter/material.dart';

class CompanyProvider with ChangeNotifier {
  List<Company> _companies = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Company> get companies => _companies;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Company> get visibleCompanies {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _companies;

    return _companies.where((company) {
      return company.name.toLowerCase().contains(query) ||
          company.taxId.toLowerCase().contains(query);
    }).toList();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void clear() {
    _companies = [];
    _searchQuery = '';
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  Future<bool> load() async {
    _setLoading(true);
    _setError(null);

    try {
      _companies = await ApiService.getCompanies();
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> add(Company company) async {
    _setLoading(true);
    _setError(null);

    try {
      final createdCompany = await ApiService.createCompany(company);
      _companies.insert(0, createdCompany);
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> update(int id, Company company) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedCompany = await ApiService.updateCompany(id, company);
      final index = companies.indexWhere((company) => company.id == id);
      if (index != -1) {
        _companies[index] = updatedCompany;
      }
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> remove(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      await ApiService.deleteCompany(id);
      _companies.removeWhere((company) => company.id == id);
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
}
