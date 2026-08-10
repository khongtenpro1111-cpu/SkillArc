// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num?)?.toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  avatarPath: json['avatarPath'] as String?,
  bio: json['bio'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  githubUrl: json['githubUrl'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'fullName': instance.fullName,
  'avatarUrl': instance.avatarUrl,
  'avatarPath': instance.avatarPath,
  'bio': instance.bio,
  'phoneNumber': instance.phoneNumber,
  'githubUrl': instance.githubUrl,
};
