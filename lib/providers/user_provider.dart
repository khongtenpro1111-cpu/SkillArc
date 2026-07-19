import 'package:flutter/material.dart';
import 'package:skill_arc/models/user.dart';
import 'package:skill_arc/services/auth_service.dart';
import 'package:skill_arc/services/local_db_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  double _studyHours = 0.0; 
  double _studyProgress = 0.0;
  int _targetHoursPerDay = 2;

  User? get currentUser => _currentUser;
  double get studyHours => _studyHours;
  double get studyProgress => _studyProgress;
  int get targetHoursPerDay => _targetHoursPerDay;

  UserProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    _currentUser = await _authService.getCurrentUser();
    
    // Lấy dữ liệu thực tế từ LocalDb
    _studyHours = LocalDbService.getTodayStudyHours();
    final goal = LocalDbService.getGoal();
    if (goal != null) {
      _targetHoursPerDay = goal['hoursPerDay'] ?? 2;
      _studyProgress = (_studyHours / _targetHoursPerDay).clamp(0.0, 1.0);
    }

    notifyListeners();
  }

  Future<void> addStudyTime(double hours) async {
    _studyHours += hours;
    await LocalDbService.saveTodayStudyHours(_studyHours);
    
    if (_targetHoursPerDay > 0) {
      _studyProgress = (_studyHours / _targetHoursPerDay).clamp(0.0, 1.0);
    }
    notifyListeners();
  }

  Future<void> updateAvatar(String path) async {
    if (_currentUser != null) {
      await LocalDbService.updateUserProfile(
        fullName: _currentUser!.fullName ?? _currentUser!.username,
        email: _currentUser!.email,
        avatarPath: path,
      );
      await loadUser();
    }
  }
}
