import 'package:equatable/equatable.dart';
import 'package:images/src/utils/enum.dart';

class Lesson extends Equatable {
  final String id;
  final String title;
  final String unit;
  final LessonType type;
  final double progress;
  final String levelTag;
  final bool isNew;
  final int minutesLeft;

  const Lesson({
    required this.id,
    required this.title,
    required this.unit,
    required this.type,
    required this.progress,
    required this.levelTag,
    this.isNew = false,
    required this.minutesLeft,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    unit,
    type,
    progress,
    levelTag,
    isNew,
    minutesLeft,
  ];
}
