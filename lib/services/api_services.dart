import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:crud_withnodejs/models/auth_session.dart';
import 'package:crud_withnodejs/models/company.dart';
import 'package:crud_withnodejs/models/employee.dart';
import 'package:crud_withnodejs/services/auth_storage.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  static String get _normalizedBaseUrl => apiBaseUrl.endsWith('/')
      ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
      : apiBaseUrl;

  static Uri _uri(String path, {Map<String, String?>? queryParameters}) {
    final cleanedQueryParameters = <String, String>{};

    queryParameters?.forEach((key, value) {
      if (value != null && value.trim().isNotEmpty) {
        cleanedQueryParameters[key] = value;
      }
    });

    return Uri.parse('$_normalizedBaseUrl$path').replace(
      queryParameters: cleanedQueryParameters.isEmpty
          ? null
          : cleanedQueryParameters,
    );
  }

  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};

    if (!withAuth) return headers;

    final token = await AuthStorage.readToken();
    if (token == null) throw ApiException('Inicia sesión para continuar.');

    return {...headers, 'Authorization': 'Bearer $token'};
  }

  static Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('No se pudo conectar con el servidor.');
    }
  }

  static void _ensureSuccess(
    http.Response response,
    List<int> statusCodes,
    String fallbackMessage,
  ) {
    if (statusCodes.contains(response.statusCode)) return;

    throw ApiException(_errorMessage(response, fallbackMessage));
  }

  static dynamic _decodeJson(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw ApiException('Respuesta inválida del servidor.');
    }
  }

  static Map<String, dynamic> _decodeObject(http.Response response) {
    final data = _decodeJson(response);
    if (data is Map<String, dynamic>) return data;

    throw ApiException('Respuesta inválida del servidor.');
  }

  static List<dynamic> _decodeList(http.Response response) {
    final data = _decodeJson(response);
    if (data is List) return data;

    throw ApiException('Respuesta inválida del servidor.');
  }

  static String _errorMessage(http.Response response, String fallbackMessage) {
    final backendError = _backendError(response);
    if (backendError != null) return backendError;

    return switch (response.statusCode) {
      401 => 'Sesión expirada. Inicia sesión nuevamente.',
      404 => 'Recurso no encontrado.',
      >= 500 => 'Error del servidor.',
      _ => fallbackMessage,
    };
  }

  static String? _backendError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) return null;

      return switch (data['error']) {
        'Unauthorized' => 'Sesión expirada. Inicia sesión nuevamente.',
        'Invalid credentials' => 'Credenciales inválidas.',
        'Email is already registered' => 'El correo ya está registrado.',
        'Valid email is required' => 'Ingresa un correo válido.',
        'Password must have at least 6 characters' =>
          'La contraseña debe tener al menos 6 caracteres.',
        'Name is required' => 'El nombre es obligatorio.',
        'Tax ID is required' => 'El RUC es obligatorio.',
        'Full name is required' => 'El nombre completo es obligatorio.',
        'Company not found' => 'Empresa no encontrada.',
        'Employee not found' => 'Empleado no encontrado.',
        'Route not found' => 'Ruta no encontrada.',
        'Internal server error' => 'Error del servidor.',
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }

  static Future<T> _requestObject<T>({
    required Future<http.Response> Function() request,
    required List<int> successStatusCodes,
    required String fallbackMessage,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await _send(request);
    _ensureSuccess(response, successStatusCodes, fallbackMessage);
    return fromJson(_decodeObject(response));
  }

  static Future<List<T>> _requestList<T>({
    required Future<http.Response> Function() request,
    required List<int> successStatusCodes,
    required String fallbackMessage,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await _send(request);
    _ensureSuccess(response, successStatusCodes, fallbackMessage);

    try {
      final items = _decodeList(response);
      return items
          .map((item) => fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      throw ApiException('Respuesta inválida del servidor.');
    }
  }

  static Future<void> _requestVoid({
    required Future<http.Response> Function() request,
    required List<int> successStatusCodes,
    required String fallbackMessage,
  }) async {
    final response = await _send(request);
    _ensureSuccess(response, successStatusCodes, fallbackMessage);
  }

  static Future<AuthSession> login(String email, String password) async {
    return _requestObject(
      request: () async => http.post(
        _uri('/auth/login'),
        headers: await _headers(withAuth: false),
        body: json.encode({'email': email, 'password': password}),
      ),
      successStatusCodes: const [200],
      fallbackMessage: 'No se pudo iniciar sesión.',
      fromJson: AuthSession.fromJson,
    );
  }

  static Future<AuthSession> register({
    required String email,
    required String password,
    String? name,
  }) async {
    return _requestObject(
      request: () async => http.post(
        _uri('/auth/register'),
        headers: await _headers(withAuth: false),
        body: json.encode({'email': email, 'password': password, 'name': name}),
      ),
      successStatusCodes: const [201],
      fallbackMessage: 'No se pudo crear la cuenta.',
      fromJson: AuthSession.fromJson,
    );
  }

  static Future<List<Company>> getCompanies({String? search}) async {
    return _requestList(
      request: () async => http.get(
        _uri('/companies', queryParameters: {'search': search}),
        headers: await _headers(),
      ),
      successStatusCodes: const [200],
      fallbackMessage: 'Error al listar empresas.',
      fromJson: Company.fromJson,
    );
  }

  static Future<Company> getCompany(int id) async {
    return _requestObject(
      request: () async =>
          http.get(_uri('/companies/$id'), headers: await _headers()),
      successStatusCodes: const [200],
      fallbackMessage: 'Error al obtener empresa.',
      fromJson: Company.fromJson,
    );
  }

  static Future<Company> createCompany(Company company) async {
    return _requestObject(
      request: () async => http.post(
        _uri('/companies'),
        headers: await _headers(),
        body: json.encode(company.toJson()),
      ),
      successStatusCodes: const [200, 201],
      fallbackMessage: 'Error al crear empresa.',
      fromJson: Company.fromJson,
    );
  }

  static Future<Company> updateCompany(int id, Company company) async {
    return _requestObject(
      request: () async => http.put(
        _uri('/companies/$id'),
        headers: await _headers(),
        body: json.encode(company.toJson()),
      ),
      successStatusCodes: const [200],
      fallbackMessage: 'Error al actualizar empresa.',
      fromJson: Company.fromJson,
    );
  }

  static Future<void> deleteCompany(int id) async {
    await _requestVoid(
      request: () async =>
          http.delete(_uri('/companies/$id'), headers: await _headers()),
      successStatusCodes: const [200],
      fallbackMessage: 'Error al eliminar empresa.',
    );
  }

  static Future<Employee> createEmployee({
    required int companyId,
    required Employee employee,
  }) async {
    return _requestObject(
      request: () async => http.post(
        _uri('/companies/$companyId/employees'),
        headers: await _headers(),
        body: json.encode(employee.toJson()),
      ),
      successStatusCodes: const [200, 201],
      fallbackMessage: 'Error al crear empleado.',
      fromJson: Employee.fromJson,
    );
  }

  static Future<Employee> updateEmployee({
    required int companyId,
    required int employeeId,
    required Employee employee,
  }) async {
    return _requestObject(
      request: () async => http.put(
        _uri('/companies/$companyId/employees/$employeeId'),
        headers: await _headers(),
        body: json.encode(employee.toJson()),
      ),
      successStatusCodes: const [200],
      fallbackMessage: 'Error al actualizar empleado.',
      fromJson: Employee.fromJson,
    );
  }

  static Future<void> deleteEmployee({
    required int companyId,
    required int employeeId,
  }) async {
    await _requestVoid(
      request: () async => http.delete(
        _uri('/companies/$companyId/employees/$employeeId'),
        headers: await _headers(),
      ),
      successStatusCodes: const [200],
      fallbackMessage: 'Error al eliminar empleado.',
    );
  }
}
