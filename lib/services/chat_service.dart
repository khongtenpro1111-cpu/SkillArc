import 'package:flutter/foundation.dart';
import 'package:skill_arc/core/api_client.dart';

class ChatService {
  final _apiClient = ApiClient();

  Future<String> sendMessage(String message) async {
    try {
      final response = await _apiClient.dio.post('/chat', data: {
        'message': message,
      });
      return response.data['reply'] ?? 'Không nhận được phản hồi.';
    } catch (e) {
      debugPrint('Send message error: $e');
      return 'Lỗi kết nối Trợ lý SkillArc: $e';
    }
  }
}