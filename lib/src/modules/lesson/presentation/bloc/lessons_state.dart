// ═══════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════

import 'package:equatable/equatable.dart';
import 'package:images/src/modules/lesson/domain/lessons_unit.dart';

abstract class LessonsState extends Equatable {
  const LessonsState();
  @override
  List<Object?> get props => [];
}

class LessonsInitial extends LessonsState {
  const LessonsInitial();
}

class LessonsLoading extends LessonsState {
  const LessonsLoading();
}

class LessonsReady extends LessonsState {
  final List<LessonUnit> allUnits; // full unfiltered data
  final List<LessonUnit> filteredUnits; // after filter + search
  final List<LessonFilter> filters;
  final String activeFilterId;
  final String searchQuery;
  final int totalCompleted;
  final int totalLessons;

  const LessonsReady({
    required this.allUnits,
    required this.filteredUnits,
    required this.filters,
    required this.activeFilterId,
    required this.searchQuery,
    required this.totalCompleted,
    required this.totalLessons,
  });

  double get overallProgress =>
      totalLessons == 0 ? 0.0 : totalCompleted / totalLessons;

  LessonsReady copyWith({
    List<LessonUnit>? allUnits,
    List<LessonUnit>? filteredUnits,
    List<LessonFilter>? filters,
    String? activeFilterId,
    String? searchQuery,
    int? totalCompleted,
    int? totalLessons,
  }) {
    return LessonsReady(
      allUnits: allUnits ?? this.allUnits,
      filteredUnits: filteredUnits ?? this.filteredUnits,
      filters: filters ?? this.filters,
      activeFilterId: activeFilterId ?? this.activeFilterId,
      searchQuery: searchQuery ?? this.searchQuery,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      totalLessons: totalLessons ?? this.totalLessons,
    );
  }

  @override
  List<Object?> get props => [
    allUnits,
    filteredUnits,
    filters,
    activeFilterId,
    searchQuery,
    totalCompleted,
    totalLessons,
  ];
}

/// Emitted alongside LessonsReady to trigger navigation
class LessonsNavigateToLesson extends LessonsState {
  final String lessonId;
  const LessonsNavigateToLesson(this.lessonId);
  @override
  List<Object?> get props => [lessonId];
}

class LessonsError extends LessonsState {
  final String message;
  const LessonsError(this.message);
  @override
  List<Object?> get props => [message];
}
