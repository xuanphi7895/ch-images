// ── Lesson card ────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/home/domain/lesson_model.dart';
import 'package:images/src/modules/home/presentation/bloc/home_bloc.dart';
import 'package:images/src/modules/home/presentation/bloc/home_event.dart';
import 'package:images/src/modules/home/presentation/widgets/lesson_badge.dart';
import 'package:images/src/utils/color.dart';
import 'package:images/src/utils/enum.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  const LessonCard({required this.lesson});

  IconData get _icon {
    switch (lesson.type) {
      case LessonType.listening:
        return Icons.headphones_outlined;
      case LessonType.speaking:
        return Icons.chat_bubble_outline;
      case LessonType.reading:
        return Icons.book_outlined;
      case LessonType.writing:
        return Icons.edit_outlined;
      case LessonType.grammar:
        return Icons.splitscreen;
      case LessonType.vocabulary:
        return Icons.splitscreen;
    }
  }

  Color get _iconBg {
    switch (lesson.type) {
      case LessonType.listening:
        return CustomColors.Purple50;
      case LessonType.speaking:
        return CustomColors.Teal50;
      case LessonType.reading:
        return CustomColors.Coral50;
      case LessonType.writing:
        return CustomColors.Blue50;
      case LessonType.grammar:
        return CustomColors.Blue50;
      case LessonType.vocabulary:
        return CustomColors.Blue50;
    }
  }

  Color get _iconColor {
    switch (lesson.type) {
      case LessonType.listening:
        return CustomColors.Purple600;
      case LessonType.speaking:
        return CustomColors.Teal600;
      case LessonType.reading:
        return CustomColors.Coral600;
      case LessonType.writing:
        return CustomColors.Blue600;
      case LessonType.grammar:
        return CustomColors.Blue50;
      case LessonType.vocabulary:
        return CustomColors.Blue50;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<HomeBloc>().add(LessonResumed(lesson.id)),
      child: Container(
        // margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, color: _iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      LessonBadge(
                        text: lesson.isNew ? 'New' : lesson.levelTag,
                        isNew: lesson.isNew,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lesson.unit} · ${lesson.minutesLeft} min left',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: lesson.progress,
                      minHeight: 4,
                      backgroundColor: Colors.black.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(_iconColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
