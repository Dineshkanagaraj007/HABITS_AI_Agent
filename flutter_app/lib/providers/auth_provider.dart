import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

/// Manages authentication state and persists the JWT token.
class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  String? get error => _error;
  ApiService get api => _api;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    if (savedToken == null) return;

    _token = savedToken;
    _api.setToken(savedToken);
    try {
      final data = await _api.getMe();
      _user = User.fromJson(data);
      notifyListeners();
    } catch (_) {
      await logout();
    }
  }

  Future<bool> register({
    required String email,
    required String username,
    required String password,
    String fullName = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.register(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
      );
      return await login(username: username, password: password);
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.login(username: username, password: password);
      _token = data['access_token'] as String;
      _api.setToken(_token!);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      final meData = await _api.getMe();
      _user = User.fromJson(meData);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }
}
