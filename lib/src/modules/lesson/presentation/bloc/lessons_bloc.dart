// ═══════════════════════════════════════════
// BLOC
// ═══════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/lesson/domain/lessons_models.dart';
import 'package:images/src/modules/lesson/domain/lessons_unit.dart';
import 'package:images/src/modules/lesson/presentation/bloc/lessons_event.dart';
import 'package:images/src/modules/lesson/presentation/bloc/lessons_state.dart';
import 'package:images/src/utils/enum.dart';

class LessonsBloc extends Bloc<LessonsEvent, LessonsState> {
  LessonsBloc() : super(const LessonsInitial()) {
    on<LessonsLoaded>(_onLoaded);
    on<LessonsFilterChanged>(_onFilterChanged);
    on<LessonsSearchChanged>(_onSearchChanged);
    on<LessonsUnitToggled>(_onUnitToggled);
    on<LessonTapped>(_onLessonTapped);
  }

  // ── Mock data ─────────────────────────────
  static final _mockUnits = [
    LessonUnit(
      id: 'u1',
      unitNumber: 1,
      title: 'Everyday conversations',
      description: 'Greetings, introductions and small talk',
      level: LessonLevel.a1,
      isExpanded: true,
      lessons: const [
        Lesson(
          id: 'l1_1',
          title: 'Greetings & introductions',
          type: LessonType.speaking,
          status: LessonStatus.completed,
          durationMinutes: 10,
          xpReward: 30,
          description: 'Learn how to greet people and introduce yourself.',
        ),
        Lesson(
          id: 'l1_2',
          title: 'Numbers and dates',
          type: LessonType.vocabulary,
          status: LessonStatus.completed,
          durationMinutes: 8,
          xpReward: 25,
        ),
        Lesson(
          id: 'l1_3',
          title: 'Small talk at work',
          type: LessonType.listening,
          status: LessonStatus.inProgress,
          durationMinutes: 12,
          xpReward: 35,
          progress: 0.55,
        ),
        Lesson(
          id: 'l1_4',
          title: 'Present simple tense',
          type: LessonType.grammar,
          status: LessonStatus.available,
          durationMinutes: 15,
          xpReward: 40,
        ),
      ],
    ),
    LessonUnit(
      id: 'u2',
      unitNumber: 2,
      title: 'Travel & transport',
      description: 'Airports, hotels and getting around',
      level: LessonLevel.a2,
      lessons: const [
        Lesson(
          id: 'l2_1',
          title: 'At the airport',
          type: LessonType.listening,
          status: LessonStatus.available,
          durationMinutes: 14,
          xpReward: 40,
        ),
        Lesson(
          id: 'l2_2',
          title: 'Booking a hotel',
          type: LessonType.speaking,
          status: LessonStatus.locked,
          durationMinutes: 12,
          xpReward: 35,
        ),
        Lesson(
          id: 'l2_3',
          title: 'Reading transport signs',
          type: LessonType.reading,
          status: LessonStatus.locked,
          durationMinutes: 10,
          xpReward: 30,
        ),
        Lesson(
          id: 'l2_4',
          title: 'Past simple tense',
          type: LessonType.grammar,
          status: LessonStatus.locked,
          durationMinutes: 18,
          xpReward: 50,
        ),
        Lesson(
          id: 'l2_5',
          title: 'Travel vocabulary',
          type: LessonType.vocabulary,
          status: LessonStatus.locked,
          durationMinutes: 10,
          xpReward: 30,
        ),
      ],
    ),
    LessonUnit(
      id: 'u3',
      unitNumber: 3,
      title: 'Work & career',
      description: 'Office English, meetings and emails',
      level: LessonLevel.b1,
      lessons: const [
        Lesson(
          id: 'l3_1',
          title: 'Job interviews',
          type: LessonType.speaking,
          status: LessonStatus.locked,
          durationMinutes: 20,
          xpReward: 60,
        ),
        Lesson(
          id: 'l3_2',
          title: 'Writing professional emails',
          type: LessonType.writing,
          status: LessonStatus.locked,
          durationMinutes: 18,
          xpReward: 55,
        ),
        Lesson(
          id: 'l3_3',
          title: 'Running a meeting',
          type: LessonType.listening,
          status: LessonStatus.locked,
          durationMinutes: 15,
          xpReward: 45,
        ),
        Lesson(
          id: 'l3_4',
          title: 'Conditionals in business',
          type: LessonType.grammar,
          status: LessonStatus.locked,
          durationMinutes: 20,
          xpReward: 60,
        ),
      ],
    ),
    LessonUnit(
      id: 'u4',
      unitNumber: 4,
      title: 'Advanced topics',
      description: 'Debates, persuasion and academic writing',
      level: LessonLevel.b2,
      lessons: const [
        Lesson(
          id: 'l4_1',
          title: 'Expressing opinions',
          type: LessonType.speaking,
          status: LessonStatus.locked,
          durationMinutes: 20,
          xpReward: 70,
        ),
        Lesson(
          id: 'l4_2',
          title: 'Academic reading',
          type: LessonType.reading,
          status: LessonStatus.locked,
          durationMinutes: 22,
          xpReward: 65,
        ),
        Lesson(
          id: 'l4_3',
          title: 'Passive voice mastery',
          type: LessonType.grammar,
          status: LessonStatus.locked,
          durationMinutes: 18,
          xpReward: 55,
        ),
      ],
    ),
  ];

  static const _filters = [
    LessonFilter(id: 'all', label: 'All'),
    LessonFilter(
      id: 'listening',
      label: 'Listening',
      type: LessonType.listening,
    ),
    LessonFilter(id: 'speaking', label: 'Speaking', type: LessonType.speaking),
    LessonFilter(id: 'reading', label: 'Reading', type: LessonType.reading),
    LessonFilter(id: 'writing', label: 'Writing', type: LessonType.writing),
    LessonFilter(id: 'grammar', label: 'Grammar', type: LessonType.grammar),
    LessonFilter(
      id: 'vocabulary',
      label: 'Vocabulary',
      type: LessonType.vocabulary,
    ),
  ];

  // ── Helpers ───────────────────────────────

  int _countCompleted(List<LessonUnit> units) => units
      .expand((u) => u.lessons)
      .where((l) => l.status == LessonStatus.completed)
      .length;

  int _countTotal(List<LessonUnit> units) =>
      units.expand((u) => u.lessons).length;

  List<LessonUnit> _applyFilter(
    List<LessonUnit> units,
    String filterId,
    String query,
  ) {
    final filter = _filters.firstWhere((f) => f.id == filterId);
    final q = query.toLowerCase().trim();

    return units
        .map((unit) {
          var lessons = unit.lessons.where((l) {
            final matchType = filter.type == null || l.type == filter.type;
            final matchQuery = q.isEmpty || l.title.toLowerCase().contains(q);
            return matchType && matchQuery;
          }).toList();

          if (lessons.isEmpty && q.isNotEmpty) {
            // also check unit title
            if (!unit.title.toLowerCase().contains(q)) return null;
            lessons = unit.lessons;
          }

          return unit
              .copyWith(isExpanded: unit.isExpanded)
              .copyWithLessons(lessons);
        })
        .whereType<LessonUnit>()
        .toList();
  }

  // ── Handlers ──────────────────────────────

  Future<void> _onLoaded(
    LessonsLoaded event,
    Emitter<LessonsState> emit,
  ) async {
    emit(const LessonsLoading());
    await Future.delayed(const Duration(milliseconds: 600));
    final total = _countTotal(_mockUnits);
    final completed = _countCompleted(_mockUnits);
    emit(
      LessonsReady(
        allUnits: _mockUnits,
        filteredUnits: _mockUnits,
        filters: _filters,
        activeFilterId: 'all',
        searchQuery: '',
        totalCompleted: completed,
        totalLessons: total,
      ),
    );
  }

  void _onFilterChanged(
    LessonsFilterChanged event,
    Emitter<LessonsState> emit,
  ) {
    if (state is! LessonsReady) return;
    final s = state as LessonsReady;
    final filtered = _applyFilter(s.allUnits, event.filterId, s.searchQuery);
    emit(s.copyWith(activeFilterId: event.filterId, filteredUnits: filtered));
  }

  void _onSearchChanged(
    LessonsSearchChanged event,
    Emitter<LessonsState> emit,
  ) {
    if (state is! LessonsReady) return;
    final s = state as LessonsReady;
    final filtered = _applyFilter(s.allUnits, s.activeFilterId, event.query);
    emit(s.copyWith(searchQuery: event.query, filteredUnits: filtered));
  }

  void _onUnitToggled(LessonsUnitToggled event, Emitter<LessonsState> emit) {
    if (state is! LessonsReady) return;
    final s = state as LessonsReady;

    final updated = s.allUnits.map((u) {
      if (u.id == event.unitId) return u.copyWith(isExpanded: !u.isExpanded);
      return u;
    }).toList();

    final filtered = _applyFilter(updated, s.activeFilterId, s.searchQuery);
    emit(s.copyWith(allUnits: updated, filteredUnits: filtered));
  }

  void _onLessonTapped(LessonTapped event, Emitter<LessonsState> emit) {
    if (state is! LessonsReady) return;
    final s = state as LessonsReady;
    // Navigation side-effect
    emit(LessonsNavigateToLesson(event.lessonId));
    // Restore ready state so the screen stays alive
    emit(s);
  }
}

// ── Extension to support filtering lessons inside a unit ──
extension _UnitCopyWithLessons on LessonUnit {
  LessonUnit copyWithLessons(List<Lesson> lessons) => LessonUnit(
    id: id,
    unitNumber: unitNumber,
    title: title,
    description: description,
    level: level,
    lessons: lessons,
    isExpanded: isExpanded,
  );
}
