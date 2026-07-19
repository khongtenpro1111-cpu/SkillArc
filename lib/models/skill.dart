import 'package:json_annotation/json_annotation.dart';

part 'skill.g.dart';

@JsonSerializable()
class Skill {
  final int id;
  final String title;
  final String description;
  final String? iconUrl;
  final List<Skill>? children;
  final String category; // e.g., 'Frontend', 'Backend', 'DevOps'
  final int level; // 1, 2, 3... for hierarchy

  Skill({
    required this.id,
    required this.title,
    required this.description,
    this.iconUrl,
    this.children,
    required this.category,
    required this.level,
  });

  factory Skill.fromJson(Map<String, dynamic> json) => _$SkillFromJson(json);
  Map<String, dynamic> toJson() => _$SkillToJson(this);
}
