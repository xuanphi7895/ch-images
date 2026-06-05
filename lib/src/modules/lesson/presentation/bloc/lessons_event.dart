// ═══════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════

import 'package:equatable/equatable.dart';

abstract class LessonsEvent extends Equatable {
  const LessonsEvent();
  @override
  List<Object?> get props => [];
}

/// Initial load
class LessonsLoaded extends LessonsEvent {
  const LessonsLoaded();
}

/// User tapped a filter chip
class LessonsFilterChanged extends LessonsEvent {
  final String filterId;
  const LessonsFilterChanged(this.filterId);
  @override
  List<Object?> get props => [filterId];
}

/// User typed in search box
class LessonsSearchChanged extends LessonsEvent {
  final String query;
  const LessonsSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

/// User toggled a unit accordion
class LessonsUnitToggled extends LessonsEvent {
  final String unitId;
  const LessonsUnitToggled(this.unitId);
  @override
  List<Object?> get props => [unitId];
}

/// User tapped a lesson row to open it
class LessonTapped extends LessonsEvent {
  final String lessonId;
  const LessonTapped(this.lessonId);
  @override
  List<Object?> get props => [lessonId];
}
