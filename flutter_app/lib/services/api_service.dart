import 'dart:convert';
import 'package:http/http.dart' as http;

/// Central HTTP client for communicating with the FastAPI backend.
class ApiService {
  // Change this to your backend URL.  Use 10.0.2.2 for Android emulator
  // accessing localhost, or the actual server IP for real devices.
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    String fullName = '',
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'full_name': fullName,
      }),
    );
    return _handleResponse(resp);
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'username': username, 'password': password}),
    );
    return _handleResponse(resp);
  }

  Future<Map<String, dynamic>> getMe() async {
    final resp = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers,
    );
    return _handleResponse(resp);
  }

  // ── Habits ───────────────────────────────────────────────────────────────

  Future<List<dynamic>> getHabits({bool activeOnly = false}) async {
    final uri = Uri.parse('$baseUrl/habits/').replace(
      queryParameters: activeOnly ? {'active_only': 'true'} : null,
    );
    final resp = await http.get(uri, headers: _headers);
    return jsonDecode(resp.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createHabit(Map<String, dynamic> data) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/habits/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(resp);
  }

  Future<Map<String, dynamic>> updateHabit(
      String id, Map<String, dynamic> data) async {
    final resp = await http.patch(
      Uri.parse('$baseUrl/habits/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    return _handleResponse(resp);
  }

  Future<void> deleteHabit(String id) async {
    await http.delete(Uri.parse('$baseUrl/habits/$id'), headers: _headers);
  }

  Future<Map<String, dynamic>> completeHabit(
    String habitId, {
    String note = '',
    double rating = 5.0,
  }) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/habits/$habitId/complete'),
      headers: _headers,
      body: jsonEncode({'note': note, 'rating': rating}),
    );
    return _handleResponse(resp);
  }

  // ── Insights ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboard() async {
    final resp = await http.get(
      Uri.parse('$baseUrl/insights/dashboard'),
      headers: _headers,
    );
    return _handleResponse(resp);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _handleResponse(http.Response resp) {
    final body = jsonDecode(resp.body);
    if (resp.statusCode >= 400) {
      throw ApiException(
        statusCode: resp.statusCode,
        message: body['detail']?.toString() ?? 'Request failed',
      );
    }
    return body as Map<String, dynamic>;
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
