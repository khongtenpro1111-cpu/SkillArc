import 'package:flutter/foundation.dart';
import 'package:skill_arc/core/api_client.dart';

class SkillService {
  final _apiClient = ApiClient();

  // Lấy toàn bộ cây kỹ năng từ Backend
  Future<List<dynamic>> fetchSkillTree() async {
    try {
      final response = await _apiClient.dio.get('/skills/tree');
      return response.data;
    } catch (e) {
      debugPrint('Fetch Skill Tree Error: $e');
      return [];
    }
  }

  // Lấy tiến độ của người dùng hiện tại
  Future<List<dynamic>> fetchMyProgress() async {
    try {
      final response = await _apiClient.dio.get('/progress/me');
      return response.data;
    } catch (e) {
      debugPrint('Fetch Progress Error: $e');
      return [];
    }
  }

  // Cập nhật tiến độ kỹ năng
  Future<void> updateProgress(int skillId, int percentage, String status) async {
    try {
      await _apiClient.dio.post('/progress/update', data: {
        'skillId': skillId,
        'percentage': percentage,
        'status': status,
      });
    } catch (e) {
      debugPrint('Update Progress Error: $e');
      rethrow;
    }
  }

  // Lấy gợi ý lộ trình học tập
  Future<List<dynamic>> fetchRecommendations() async {
    try {
      final response = await _apiClient.dio.get('/recommendations');
      return response.data;
    } catch (e) {
      debugPrint('Fetch Recommendations Error: $e');
      return [];
    }
  }

  // Lấy danh sách nhắc nhở học tập
  Future<List<Map<String, dynamic>>> fetchReminders(String username) async {
    try {
      return [
        {'title': 'Ôn tập kỹ năng Flutter Cơ bản', 'time': '08:00', 'isUrgent': true},
        {'title': 'Làm bài tập Java Spring Boot', 'time': '14:30', 'isUrgent': false},
      ];
    } catch (e) {
      debugPrint('Fetch Reminders Error: $e');
      return [];
    }
  }
}
