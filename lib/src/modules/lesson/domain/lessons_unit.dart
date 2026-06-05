import 'package:equatable/equatable.dart';
import 'package:images/src/utils/enum.dart';
import 'package:images/src/modules/lesson/domain/lessons_models.dart';

class LessonUnit extends Equatable {
  final String id;
  final int unitNumber;
  final String title;
  final String description;
  final LessonLevel level;
  final List<Lesson> lessons;
  final bool isExpanded;

  const LessonUnit({
    required this.id,
    required this.unitNumber,
    required this.title,
    required this.description,
    required this.level,
    required this.lessons,
    this.isExpanded = false,
  });

  int get completedCount =>
      lessons.where((l) => l.status == LessonStatus.completed).length;

  double get progress =>
      lessons.isEmpty ? 0.0 : completedCount / lessons.length;

  bool get isFullyCompleted => completedCount == lessons.length;

  LessonUnit copyWith({bool? isExpanded}) => LessonUnit(
    id: id,
    unitNumber: unitNumber,
    title: title,
    description: description,
    level: level,
    lessons: lessons,
    isExpanded: isExpanded ?? this.isExpanded,
  );

  @override
  List<Object?> get props => [
    id,
    unitNumber,
    title,
    description,
    level,
    lessons,
    isExpanded,
  ];
}

// Filter chip model
class LessonFilter extends Equatable {
  final String id;
  final String label;
  final LessonType? type; // null = "All"
  final LessonLevel? level; // null = all levels

  const LessonFilter({
    required this.id,
    required this.label,
    this.type,
    this.level,
  });

  @override
  List<Object?> get props => [id, label, type, level];
}
