// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Progress _$ProgressFromJson(Map<String, dynamic> json) => Progress(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  skillId: (json['skillId'] as num).toInt(),
  completionPercentage: (json['completionPercentage'] as num).toDouble(),
  isCompleted: json['isCompleted'] as bool,
  lastAccessed: json['lastAccessed'] == null
      ? null
      : DateTime.parse(json['lastAccessed'] as String),
);

Map<String, dynamic> _$ProgressToJson(Progress instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'skillId': instance.skillId,
  'completionPercentage': instance.completionPercentage,
  'isCompleted': instance.isCompleted,
  'lastAccessed': instance.lastAccessed?.toIso8601String(),
};
