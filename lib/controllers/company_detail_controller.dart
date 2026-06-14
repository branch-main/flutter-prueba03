import 'package:flutter/material.dart';

import 'package:crud_withnodejs/models/company.dart';
import 'package:crud_withnodejs/models/employee.dart';
import 'package:crud_withnodejs/providers/company_provider.dart';

class CompanyDetailController extends ChangeNotifier {
  int? _companyId;
  Company? _company;
  bool _loadedArguments = false;
  bool _isLoading = false;
  bool _isUpdatingStatus = false;
  String? _errorMessage;
  bool _isDisposed = false;

  Company? get company => _company;
  bool get isLoading => _isLoading;
  bool get isUpdatingStatus => _isUpdatingStatus;
  String? get errorMessage => _errorMessage;

  bool loadArguments(Object? arguments) {
    if (_loadedArguments) return false;

    if (arguments is int) {
      _companyId = arguments;
    } else if (arguments is Company) {
      _companyId = arguments.id;
      _company = arguments;
    }

    _loadedArguments = true;
    _isLoading = true;
    return true;
  }

  Future<String?> load(CompanyProvider provider) async {
    final companyId = _companyId;
    if (companyId == null) {
      _errorMessage = 'Empresa no encontrada.';
      _isLoading = false;
      _notify();
      return _errorMessage;
    }

    _isLoading = true;
    _errorMessage = null;
    _notify();

    final company = await provider.getCompany(companyId);
    if (_isDisposed) return null;

    if (company == null) {
      _errorMessage = provider.errorMessage ?? 'No se pudo cargar la empresa.';
      _isLoading = false;
      _notify();
      return _errorMessage;
    }

    _company = company;
    _errorMessage = null;
    _isLoading = false;
    _notify();
    return null;
  }

  Future<String?> deleteCompany(CompanyProvider provider) async {
    final companyId = _company?.id;
    if (companyId == null) return 'Empresa no encontrada.';

    final success = await provider.remove(companyId);
    if (success) return null;

    return provider.errorMessage ?? 'No se pudo eliminar la empresa.';
  }

  Future<String?> toggleCompanyStatus(CompanyProvider provider) async {
    final company = _company;
    final companyId = company?.id;
    if (company == null || companyId == null || _isUpdatingStatus) return null;

    final nextIsActive = !company.isActive;
    _isUpdatingStatus = true;
    _notify();

    final success = await provider.update(
      companyId,
      Company(
        name: company.name,
        taxId: company.taxId,
        address: company.address,
        businessLine: company.businessLine,
        isActive: nextIsActive,
      ),
    );

    if (_isDisposed) return null;

    if (!success) {
      _errorMessage =
          provider.errorMessage ?? 'No se pudo actualizar el estado.';
      _isUpdatingStatus = false;
      _notify();
      return null;
    }

    _company = _copyCompany(company, isActive: nextIsActive);
    _errorMessage = null;
    _isUpdatingStatus = false;
    _notify();

    return nextIsActive ? 'Empresa activada.' : 'Empresa desactivada.';
  }

  Future<String?> saveEmployee({
    required CompanyProvider provider,
    required Employee? currentEmployee,
    required Employee draft,
  }) async {
    final companyId = _company?.id;
    if (companyId == null) return 'Empresa no encontrada.';

    final employeeId = currentEmployee?.id;
    final savedEmployee = employeeId == null
        ? await provider.createEmployee(companyId: companyId, employee: draft)
        : await provider.updateEmployee(
            companyId: companyId,
            employeeId: employeeId,
            employee: draft,
          );

    if (savedEmployee != null) {
      _upsertEmployee(savedEmployee);
      return null;
    }

    return provider.errorMessage ?? 'No se pudo guardar empleado.';
  }

  Future<String?> deleteEmployee({
    required CompanyProvider provider,
    required Employee employee,
  }) async {
    final companyId = _company?.id;
    final employeeId = employee.id;
    if (companyId == null || employeeId == null) {
      return 'Empleado no encontrado.';
    }

    final success = await provider.removeEmployee(
      companyId: companyId,
      employeeId: employeeId,
    );

    if (!success) {
      return provider.errorMessage ?? 'No se pudo eliminar el empleado.';
    }

    _removeEmployee(employeeId);
    return null;
  }

  void _upsertEmployee(Employee employee) {
    final company = _company;
    if (company == null) return;

    final employees = [...company.employees];
    final index = employees.indexWhere((item) => item.id == employee.id);

    if (index == -1) {
      employees.insert(0, employee);
    } else {
      employees[index] = employee;
    }

    _company = _copyCompany(company, employees: employees);
    _errorMessage = null;
    _notify();
  }

  void _removeEmployee(int employeeId) {
    final company = _company;
    if (company == null) return;

    _company = _copyCompany(
      company,
      employees: company.employees
          .where((employee) => employee.id != employeeId)
          .toList(),
    );
    _errorMessage = null;
    _notify();
  }

  Company _copyCompany(
    Company company, {
    bool? isActive,
    List<Employee>? employees,
  }) {
    return Company(
      id: company.id,
      name: company.name,
      taxId: company.taxId,
      address: company.address,
      businessLine: company.businessLine,
      isActive: isActive ?? company.isActive,
      employees: employees ?? company.employees,
    );
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
