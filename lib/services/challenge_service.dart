import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:skill_arc/core/api_client.dart';
import '../models/challenge.dart';

class ChallengeService {
  static const String _boxName = 'challengeBox';
  final _apiClient = ApiClient();
  
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  static Future<void> resetAllChallenges() async {
    final box = Hive.box(_boxName);
    await box.clear();
  }

  static List<Challenge> getAllChallenges() {
    final box = Hive.box(_boxName);
    return box.values.map((e) => Challenge.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  // Lấy danh sách thử thách từ Backend
  Future<List<Challenge>> fetchChallenges() async {
    try {
      final response = await _apiClient.dio.get('/challenges');
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data;
        final box = Hive.box(_boxName);
        
        List<Challenge> challenges = [];
        bool previousChallengeDone = true; // Thử thách đầu tiên luôn mở
        
        for (var item in list) {
          final String id = item['id'].toString();
          final String title = item['title'] ?? '';
          final String content = item['content'] ?? '';
          final String typeStr = item['type'] ?? 'CODING';
          final String diffStr = item['difficulty'] ?? 'MEDIUM';
          final int points = item['points'] ?? 100;
          
          ChallengeType type = typeStr.toLowerCase() == 'quiz' ? ChallengeType.quiz : ChallengeType.coding;
          
          Color color;
          if (diffStr == 'EASY') {
            color = Colors.green;
          } else if (diffStr == 'HARD') {
            color = Colors.redAccent;
          } else {
            color = Colors.orange;
          }
          
          String question = content;
          List<String> options = [];
          int correctAnswerIndex = 0;
          
          if (type == ChallengeType.quiz && content.contains('|')) {
            final parts = content.split('|');
            question = parts[0].trim();
            final correctAnswer = parts[1].trim();
            
            // Tạo các lựa chọn trắc nghiệm sinh động
            options = [
              correctAnswer,
              'Giải pháp không sử dụng đánh chỉ mục (Index)',
              'Xóa bớt dữ liệu thừa trên bảng lớn',
              'Sử dụng mệnh đề WHERE phức tạp không tối ưu',
            ];
            correctAnswerIndex = 0;
          }
          
          // Trạng thái mặc định
          ChallengeStatus status = ChallengeStatus.locked;
          double progress = 0.0;
          
          // Đồng bộ trạng thái đã làm từ Hive cục bộ
          final localData = box.get(id);
          if (localData != null) {
            final localChallenge = Challenge.fromMap(Map<String, dynamic>.from(localData));
            status = localChallenge.status;
            progress = localChallenge.progress;
          }
          
          // Mở khóa thử thách nếu thử thách trước đó đã hoàn thành
          if (previousChallengeDone && status == ChallengeStatus.locked) {
            status = ChallengeStatus.inProgress;
          }
          
          // Cập nhật trạng thái cho vòng lặp tiếp theo
          previousChallengeDone = (status == ChallengeStatus.done);
          
          final challenge = Challenge(
            id: id,
            title: title,
            description: content.contains('|') ? content.split('|')[0].trim() : content,
            reward: '$points XP',
            progress: progress,
            color: color,
            status: status,
            type: type,
            question: type == ChallengeType.quiz ? question : null,
            options: type == ChallengeType.quiz ? options : null,
            correctAnswerIndex: type == ChallengeType.quiz ? correctAnswerIndex : null,
          );
          
          challenges.add(challenge);
          await box.put(id, challenge.toMap());
        }
        return challenges;
      }
    } catch (e) {
      debugPrint('Error fetching challenges from backend: $e');
    }
    
    // Trả về danh sách offline từ Hive nếu lỗi kết nối
    return getAllChallenges();
  }

  Future<bool> submitQuiz(String challengeId, int selectedIndex) async {
    try {
      final response = await _apiClient.dio.post(
        '/submissions/challenge/$challengeId',
        data: selectedIndex.toString(),
        options: Options(contentType: Headers.textPlainContentType),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final bool isPassed = data['passed'] == true || data['isPassed'] == true;
        if (isPassed) {
          await _markAsDoneLocal(challengeId);
          return true;
        }
      }
    } catch (e) {
      debugPrint('API Error submitting quiz: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> submitCodingChallenge(String challengeId, {String? solutionUrl}) async {
    try {
      final response = await _apiClient.dio.post(
        '/submissions/challenge/$challengeId',
        data: solutionUrl ?? '',
        options: Options(contentType: Headers.textPlainContentType),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final bool isPassed = data['passed'] == true || data['isPassed'] == true;
        if (isPassed) {
          await _markAsDoneLocal(challengeId);
        }
        return Map<String, dynamic>.from(data);
      }
    } catch (e) {
      debugPrint('API Error submitting coding challenge: $e');
    }
    return null;
  }

  Future<void> _markAsDoneLocal(String challengeId) async {
    final box = Hive.box(_boxName);
    final data = box.get(challengeId);
    if (data != null) {
      final challenge = Challenge.fromMap(Map<String, dynamic>.from(data));
      final updated = challenge.copyWith(status: ChallengeStatus.done, progress: 1.0);
      await box.put(challengeId, updated.toMap());
      await box.flush();
    }
  }

  Future<Map<String, dynamic>?> getLatestSubmission(String challengeId) async {
    try {
      final response = await _apiClient.dio.get('/submissions/challenge/$challengeId/latest');
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      debugPrint('API Error getting latest submission: $e');
    }
    return null;
  }
}
