import 'package:flutter/material.dart';
import 'package:skill_arc/services/skill_service.dart';

class SkillNode {
  final String id;
  final String title;
  final String? parentId;
  final bool isCompleted;
  final String description;

  SkillNode({
    required this.id,
    required this.title,
    this.parentId,
    this.isCompleted = false,
    this.description = '',
  });

  SkillNode copyWith({bool? isCompleted}) {
    return SkillNode(
      id: id,
      title: title,
      parentId: parentId,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description,
    );
  }

  factory SkillNode.fromJson(Map<String, dynamic> json, {bool completed = false}) {
    return SkillNode(
      id: json['id'].toString(),
      title: json['title'],
      parentId: json['parent_id']?.toString(),
      description: json['description'] ?? '',
      isCompleted: completed,
    );
  }
}

class SkillProvider extends ChangeNotifier {
  final SkillService _skillService = SkillService();
  
  List<SkillNode> _skills = [];
  Map<String, SkillNode> _skillMap = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<SkillNode> get skills => _skills;
  Map<String, SkillNode> get skillMap => _skillMap;

  SkillProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      await refreshData();
    } catch (e) {
      debugPrint('SkillProvider Init Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final rawSkills = await _skillService.fetchSkillTree();
      final rawProgress = await _skillService.fetchMyProgress();
      
      Set<String> completedIds = {};
      for (var p in rawProgress) {
        if (p['status'] == 'COMPLETED') {
          completedIds.add(p['skill']['id'].toString());
        }
      }

      List<SkillNode> flatList = [];
      void flatten(List<dynamic> nodes, String? parentId) {
        for (var node in nodes) {
          String currentId = node['id'].toString();
          flatList.add(SkillNode.fromJson(node, completed: completedIds.contains(currentId)));
          if (node['children'] != null) {
            flatten(node['children'], currentId);
          }
        }
      }
      flatten(rawSkills, null);

      _skills = flatList;
      _skillMap = {for (var s in _skills) s.id: s};
    } catch (e) {
      debugPrint('refreshData Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isSkillLocked(String skillId) {
    final skill = _skillMap[skillId];
    if (skill == null || skill.parentId == null) return false;

    final parent = _skillMap[skill.parentId];
    return parent != null && !parent.isCompleted;
  }

  int getNodeDepth(String skillId) {
    int depth = 0;
    String? parentId = _skillMap[skillId]?.parentId;
    while (parentId != null) {
      depth++;
      parentId = _skillMap[parentId]?.parentId;
    }
    return depth;
  }

  bool isLastChild(String skillId) {
    final skill = _skillMap[skillId];
    if (skill == null || skill.parentId == null) return false;

    final parentId = skill.parentId;
    final siblings = _skills.where((s) => s.parentId == parentId).toList();
    if (siblings.isEmpty) return false;
    return siblings.last.id == skillId;
  }

  String? getLockReason(String skillId) {
    final skill = _skillMap[skillId];
    if (skill == null || skill.parentId == null) return null;

    final parent = _skillMap[skill.parentId];
    if (parent != null && !parent.isCompleted) {
      return parent.title;
    }
    return null;
  }

  Future<void> toggleSkillStatus(String skillId) async {
    final skill = _skillMap[skillId];
    if (skill == null) return;

    final bool newStatus = !skill.isCompleted;
    
    if (newStatus && isSkillLocked(skillId)) {
      throw 'prerequisiteError';
    }

    try {
      await _skillService.updateProgress(
        int.parse(skillId), 
        newStatus ? 100 : 0, 
        newStatus ? 'COMPLETED' : 'IN_PROGRESS'
      );

      final index = _skills.indexWhere((s) => s.id == skillId);
      _skills[index] = skill.copyWith(isCompleted: newStatus);
      _skillMap[skillId] = _skills[index];
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  double get overallProgress {
    if (_skills.isEmpty) return 0.0;
    return completedSkillsCount / _skills.length;
  }

  int get completedSkillsCount => _skills.where((s) => s.isCompleted).length;
  int get remainingSkillsCount => _skills.length - completedSkillsCount;
  
  List<SkillNode> get inProgressSkills {
    return _skills.where((s) => !s.isCompleted && !isSkillLocked(s.id)).toList();
  }

  Map<String, double> getCategoryProgress() {
    final Map<String, double> progressMap = {};
    // Lấy các nhóm gốc (nhóm kỹ năng chính có parentId == null)
    final groups = _skills.where((s) => s.parentId == null).toList();
    for (var group in groups) {
      final children = _skills.where((s) => s.parentId == group.id).toList();
      if (children.isEmpty) {
        progressMap[group.title] = 0.0;
      } else {
        final completed = children.where((s) => s.isCompleted).length;
        progressMap[group.title] = completed / children.length;
      }
    }
    return progressMap;
  }
}
