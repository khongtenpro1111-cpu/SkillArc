// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Skill _$SkillFromJson(Map<String, dynamic> json) => Skill(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  iconUrl: json['iconUrl'] as String?,
  children: (json['children'] as List<dynamic>?)
      ?.map((e) => Skill.fromJson(e as Map<String, dynamic>))
      .toList(),
  category: json['category'] as String,
  level: (json['level'] as num).toInt(),
);

Map<String, dynamic> _$SkillToJson(Skill instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'iconUrl': instance.iconUrl,
  'children': instance.children,
  'category': instance.category,
  'level': instance.level,
};
