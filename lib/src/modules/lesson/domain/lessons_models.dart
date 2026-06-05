import 'package:equatable/equatable.dart';
import 'package:images/src/utils/enum.dart';

class Lesson extends Equatable {
  final String id;
  final String title;
  final LessonType type;
  final LessonStatus status;
  final int durationMinutes;
  final double progress; // 0.0–1.0 for inProgress lessons
  final int xpReward;
  final String? description;

  const Lesson({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.durationMinutes,
    required this.xpReward,
    this.progress = 0.0,
    this.description,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    status,
    durationMinutes,
    progress,
    xpReward,
  ];
}
