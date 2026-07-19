import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:skill_arc/services/local_db_service.dart';

class SkillService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080/api',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  bool canUnlockSkill(String skillId, String? parentId) {
    if (parentId == null || parentId.isEmpty) return true;
    return LocalDbService.isSkillCompleted(parentId);
  }

  Future<void> toggleSkillCompletion(String skillId, String? parentId) async {
    if (!canUnlockSkill(skillId, parentId)) {
      throw 'Bạn cần hoàn thành kỹ năng tiền đề trước!';
    }
    final progressBox = Hive.box('progressBox');
    bool currentStatus = progressBox.get(skillId, defaultValue: false);
    bool newStatus = !currentStatus;
    try {
      final user = LocalDbService.getUser();
      if (user != null) {
        await _dio.post('/skills/sync-progress', data: {
          'username': user['username'],
          'skillId': skillId,
          'completed': newStatus,
        });
      }
      await progressBox.put(skillId, newStatus);
      await progressBox.flush();
    } catch (e) {
      await progressBox.put(skillId, newStatus);
      await progressBox.flush();
    }
  }

  Future<Map<String, bool>> fetchInitialProgress(String username) async {
    try {
      final response = await _dio.get('/skills/progress/$username');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return data.map((key, value) => MapEntry(key, value as bool));
      }
    } catch (e) {
      print('Fetch Error: $e');
    }
    return {};
  }

  // Dashboard Logic - Mock API
  Future<List<Map<String, dynamic>>> fetchReminders(String username) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'title': 'Ôn tập Docker', 'time': '09:00 AM', 'isUrgent': true},
      {'title': 'Làm bài tập SQL', 'time': '02:30 PM', 'isUrgent': false},
    ];
  }
}
