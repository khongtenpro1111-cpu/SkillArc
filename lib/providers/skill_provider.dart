import 'package:flutter/material.dart';
import 'package:skill_arc/services/skill_service.dart';
import 'package:skill_arc/services/local_db_service.dart';

class SkillNode {
  final String id;
  final String title;
  final String? parentId;
  bool isCompleted;

  SkillNode({
    required this.id,
    required this.title,
    this.parentId,
    this.isCompleted = false,
  });
}

class SkillProvider extends ChangeNotifier {
  final SkillService _skillService = SkillService();
  
  List<SkillNode> _skills = [
    SkillNode(id: '1', title: 'Lập trình căn bản (C/C++)', parentId: null),
    SkillNode(id: '2', title: 'Cấu trúc dữ liệu & Giải thuật', parentId: '1'),
    SkillNode(id: '3', title: 'Cơ sở dữ liệu SQL', parentId: '2'),
    SkillNode(id: '4', title: 'Backend với ASP.NET Core', parentId: '3'),
    SkillNode(id: '5', title: 'Docker & Microservices', parentId: '4'),
    SkillNode(id: '6', title: 'Cloud Deployment (Azure/AWS)', parentId: '5'),
  ];

  List<SkillNode> get skills => _skills;

  SkillProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _loadLocalProgress();
    await _syncWithBackend();
  }

  void _loadLocalProgress() {
    for (var skill in _skills) {
      skill.isCompleted = LocalDbService.isSkillCompleted(skill.id);
    }
    notifyListeners();
  }

  Future<void> _syncWithBackend() async {
    final user = LocalDbService.getUser();
    if (user != null) {
      final backendProgress = await _skillService.fetchInitialProgress(user['username']);
      if (backendProgress.isNotEmpty) {
        for (var skill in _skills) {
          if (backendProgress.containsKey(skill.id)) {
            skill.isCompleted = backendProgress[skill.id]!;
            await LocalDbService.updateProgress(skill.id, skill.isCompleted);
          }
        }
        notifyListeners();
      }
    }
  }

  bool isSkillLocked(String skillId) {
    try {
      final skill = _skills.firstWhere((s) => s.id == skillId);
      if (skill.parentId == null) return false;

      final parent = _skills.firstWhere((s) => s.id == skill.parentId);
      // Một kỹ năng bị khóa nếu cha nó chưa xong HOẶC cha nó cũng đang bị khóa (tính bắc cầu)
      if (!parent.isCompleted) return true;
      return isSkillLocked(parent.id);
    } catch (e) {
      return false;
    }
  }

  String? getLockReason(String skillId) {
    try {
      final skill = _skills.firstWhere((s) => s.id == skillId);
      if (skill.parentId == null) return null;
      
      final parent = _skills.firstWhere((s) => s.id == skill.parentId);
      if (!parent.isCompleted) {
        return 'Yêu cầu: ${parent.title}';
      }
      return getLockReason(parent.id);
    } catch (e) {
      return null;
    }
  }

  SkillNode? getParentSkill(String skillId) {
    try {
      final skill = _skills.firstWhere((s) => s.id == skillId);
      if (skill.parentId == null) return null;
      return _skills.firstWhere((s) => s.id == skill.parentId);
    } catch (e) {
      return null;
    }
  }

  Future<void> toggleSkillStatus(String skillId) async {
    final index = _skills.indexWhere((s) => s.id == skillId);
    if (index == -1) return;

    final skill = _skills[index];
    
    if (!skill.isCompleted) {
      if (isSkillLocked(skillId)) {
        throw 'Bạn phải hoàn thành kỹ năng tiền đề trước!';
      }
    } else {
      bool hasCompletedChildren = _skills.any((s) => s.parentId == skillId && s.isCompleted);
      if (hasCompletedChildren) {
        throw 'Không thể bỏ hoàn thành vì có kỹ năng cấp sau đã đạt được!';
      }
    }

    try {
      await _skillService.toggleSkillCompletion(skillId, skill.parentId);
      _skills[index].isCompleted = !skill.isCompleted;
      // Cập nhật Local DB để đảm bảo offline/reload vẫn giữ trạng thái
      await LocalDbService.updateProgress(skillId, _skills[index].isCompleted);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Dashboard Logic
  double get overallProgress {
    if (_skills.isEmpty) return 0.0;
    return completedSkillsCount / _skills.length;
  }

  int get completedSkillsCount => _skills.where((s) => s.isCompleted).length;
  
  int get remainingSkillsCount => _skills.length - completedSkillsCount;

  List<SkillNode> get inProgressSkills {
    return _skills.where((s) => !s.isCompleted && !isSkillLocked(s.id)).toList();
  }
}
