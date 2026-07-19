import 'package:json_annotation/json_annotation.dart';

part 'progress.g.dart';

@JsonSerializable()
class Progress {
  final int id;
  final int userId;
  final int skillId;
  final double completionPercentage; // 0.0 to 100.0
  final bool isCompleted;
  final DateTime? lastAccessed;

  Progress({
    required this.id,
    required this.userId,
    required this.skillId,
    required this.completionPercentage,
    required this.isCompleted,
    this.lastAccessed,
  });

  factory Progress.fromJson(Map<String, dynamic> json) => _$ProgressFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressToJson(this);
}
