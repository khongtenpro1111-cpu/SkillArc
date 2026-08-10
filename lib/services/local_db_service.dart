import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class LocalDbService {
  static final _userBox = Hive.box('userBox');
  static final _progressBox = Hive.box('progressBox');

  // Sử dụng Named Parameters ({}) để code rõ ràng và khớp với AuthService
  static Future<void> saveUser({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    await _userBox.put('currentUser', {
      'username': username,
      'email': email,
      'password': password,
      'fullName': fullName ?? username,
      'isLoggedIn': true,
    });
    // Lưu xuống đĩa
    await _userBox.flush();
    debugPrint('DEBUG: Đã lưu user vào Hive: $username');
  }

  static Future<void> updateUserProfile({
    required String fullName,
    required String email,
    String? avatarPath,
    String? bio,
    String? phoneNumber,
    String? githubUrl,
  }) async {
    final user = getUser() ?? {};
    user['fullName'] = fullName;
    user['email'] = email;
    if (avatarPath != null) {
      user['avatarPath'] = avatarPath;
    }
    if (bio != null) {
      user['bio'] = bio;
    }
    if (phoneNumber != null) {
      user['phoneNumber'] = phoneNumber;
    }
    if (githubUrl != null) {
      user['githubUrl'] = githubUrl;
    }
    await _userBox.put('currentUser', user);
    await _userBox.flush();
  }

  static Future<void> saveGoal(Map<String, dynamic> goal) async {
    await _userBox.put('learningGoal', goal);
    await _userBox.flush();
  }

  static Map<dynamic, dynamic>? getGoal() {
    final goal = _userBox.get('learningGoal');
    return goal != null ? Map<dynamic, dynamic>.from(goal) : null;
  }

  static Map<dynamic, dynamic>? getUser() {
    final user = _userBox.get('currentUser');
    return user != null ? Map<dynamic, dynamic>.from(user) : null;
  }

  static double getTodayStudyHours() {
    final dateKey = _getTodayKey();
    return _userBox.get('study_hours_$dateKey', defaultValue: 0.0);
  }

  static Future<void> saveTodayStudyHours(double hours) async {
    final dateKey = _getTodayKey();
    await _userBox.put('study_hours_$dateKey', hours);
    await _userBox.flush();
  }

  static String _getTodayKey() {
    final now = DateTime.now();
    return "${now.year}_${now.month}_${now.day}";
  }

  static bool isSkillCompleted(String skillId) {
    return _progressBox.get(skillId, defaultValue: false);
  }

  static Future<void> updateProgress(String skillId, bool isCompleted) async {
    await _progressBox.put(skillId, isCompleted);
    await _progressBox.flush();
  }

  static List<String> getCompletedSkillIds() {
    return _progressBox.keys.cast<String>().where((key) => _progressBox.get(key) == true).toList();
  }

  static Future<void> logout() async {
    final user = getUser();
    if (user != null) {
      user['isLoggedIn'] = false;
      await _userBox.put('currentUser', user);
      await _userBox.flush();
    }
  }
}
