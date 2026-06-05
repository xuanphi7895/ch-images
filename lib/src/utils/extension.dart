import 'package:images/src/utils/enum.dart';

extension LessonLevelLabel on LessonLevel {
  String get label {
    switch (this) {
      case LessonLevel.a1:
        return 'A1';
      case LessonLevel.a2:
        return 'A2';
      case LessonLevel.b1:
        return 'B1';
      case LessonLevel.b2:
        return 'B2';
      case LessonLevel.c1:
        return 'C1';
    }
  }
}

extension LessonTypeLabel on LessonType {
  String get label {
    switch (this) {
      case LessonType.listening:
        return 'Listening';
      case LessonType.speaking:
        return 'Speaking';
      case LessonType.reading:
        return 'Reading';
      case LessonType.writing:
        return 'Writing';
      case LessonType.grammar:
        return 'Grammar';
      case LessonType.vocabulary:
        return 'Vocabulary';
    }
  }
}
