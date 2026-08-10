import 'package:flutter/material.dart';

enum ChallengeType { quiz, coding }
enum ChallengeStatus { inProgress, done, locked }

class Challenge {
  final String id;
  final String title;
  final String description;
  final String reward;
  final double progress;
  final Color color;
  final ChallengeStatus status;
  final ChallengeType type;
  
  // Quiz specific fields
  final String? question;
  final List<String>? options;
  final int? correctAnswerIndex;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.progress,
    required this.color,
    required this.status,
    required this.type,
    this.question,
    this.options,
    this.correctAnswerIndex,
  });

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? reward,
    double? progress,
    Color? color,
    ChallengeStatus? status,
    ChallengeType? type,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reward: reward ?? this.reward,
      progress: progress ?? this.progress,
      color: color ?? this.color,
      status: status ?? this.status,
      type: type ?? this.type,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reward': reward,
      'progress': progress,
      'color': color.toARGB32(),
      'status': status.name,
      'type': type.name,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      reward: map['reward'],
      progress: (map['progress'] as num).toDouble(),
      color: Color(map['color']),
      status: ChallengeStatus.values.firstWhere((e) => e.name == map['status']),
      type: ChallengeType.values.firstWhere((e) => e.name == map['type']),
      question: map['question'],
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      correctAnswerIndex: map['correctAnswerIndex'],
    );
  }
}
