import 'package:flutter/material.dart';

import 'package:crud_withnodejs/models/auth_session.dart';
import 'package:crud_withnodejs/models/auth_user.dart';
import 'package:crud_withnodejs/services/api_services.dart';
import 'package:crud_withnodejs/services/auth_storage.dart';

class AuthProvider with ChangeNotifier {
  AuthUser? _user;
  bool _isLoading = true;
  bool _hasLoadedSession = false;
  String? _errorMessage;

  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLoadedSession => _hasLoadedSession;
  bool get isAuthenticated => _user != null;

  Future<void> loadSession() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final token = await AuthStorage.readToken();
      _user = token == null ? null : await AuthStorage.readUser();
    } catch (error) {
      _user = null;
      _errorMessage = error.toString();
    } finally {
      _hasLoadedSession = true;
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final session = await ApiService.login(email, password);
      await _saveSession(session);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? name,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final session = await ApiService.register(
        email: email,
        password: password,
        name: name,
      );
      await _saveSession(session);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await AuthStorage.clear();
      _user = null;
      _errorMessage = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _saveSession(AuthSession session) async {
    await AuthStorage.saveSession(session);
    _user = session.user;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
