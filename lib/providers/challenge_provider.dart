import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';

class ChallengeProvider with ChangeNotifier {
  final ChallengeService _service = ChallengeService();
  List<Challenge> _challenges = [];
  bool _isLoading = false;

  List<Challenge> get challenges => _challenges;
  bool get isLoading => _isLoading;

  ChallengeProvider() {
    loadChallenges();
  }

  Future<void> loadChallenges() async {
    _isLoading = true;
    notifyListeners();
    try {
      _challenges = await _service.fetchChallenges();
    } catch (e) {
      debugPrint('Load Challenges Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitQuiz(String challengeId, int selectedIndex) async {
    final bool success = await _service.submitQuiz(challengeId, selectedIndex);
    if (success) {
      await loadChallenges();
    }
    return success;
  }

  Future<Map<String, dynamic>?> submitCodingChallenge(String challengeId, {String? solutionUrl}) async {
    final Map<String, dynamic>? result = await _service.submitCodingChallenge(challengeId, solutionUrl: solutionUrl);
    if (result != null) {
      await loadChallenges();
    }
    return result;
  }

  Future<void> resetChallenges() async {
    await ChallengeService.resetAllChallenges();
    await loadChallenges();
  }

  Future<Map<String, dynamic>?> getLatestSubmission(String challengeId) async {
    return await _service.getLatestSubmission(challengeId);
  }
}
