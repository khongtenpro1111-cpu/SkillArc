import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int? id;
  final String username;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? avatarPath;

  User({
    this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.avatarPath,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
