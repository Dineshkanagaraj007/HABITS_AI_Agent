import 'package:flutter/foundation.dart';
import '../models/dashboard.dart';
import '../models/habit.dart';
import '../services/api_service.dart';

/// Manages habit data and communicates with the backend.
class HabitProvider extends ChangeNotifier {
  ApiService? _api;
  List<Habit> _habits = [];
  Dashboard? _dashboard;
  bool _isLoading = false;
  String? _error;

  List<Habit> get habits => _habits;
  Dashboard? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setApi(ApiService api) {
    _api = api;
  }

  Future<void> fetchHabits() async {
    if (_api == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api!.getHabits();
      _habits = data.map((e) => Habit.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createHabit({
    required String title,
    String description = '',
    String category = 'general',
    String frequency = 'daily',
    int targetCount = 1,
  }) async {
    if (_api == null) return false;
    try {
      final data = await _api!.createHabit({
        'title': title,
        'description': description,
        'category': category,
        'frequency': frequency,
        'target_count': targetCount,
      });
      _habits.insert(0, Habit.fromJson(data));
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeHabit(String habitId, {String note = '', double rating = 5.0}) async {
    if (_api == null) return false;
    try {
      await _api!.completeHabit(habitId, note: note, rating: rating);
      await fetchHabits();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteHabit(String habitId) async {
    if (_api == null) return false;
    try {
      await _api!.deleteHabit(habitId);
      _habits.removeWhere((h) => h.id == habitId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchDashboard() async {
    if (_api == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api!.getDashboard();
      _dashboard = Dashboard.fromJson(data);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
