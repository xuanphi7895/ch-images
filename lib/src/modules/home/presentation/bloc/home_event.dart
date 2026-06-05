import 'package:equatable/equatable.dart';
import 'package:images/src/utils/enum.dart';

// Events — what the user does:

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoaded extends HomeEvent {
  const HomeLoaded();
}

class LessonResumed extends HomeEvent {
  final String lessonId;
  const LessonResumed(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class QuickPracticeTapped extends HomeEvent {
  final SkillType skill;
  const QuickPracticeTapped(this.skill);

  @override
  List<Object?> get props => [skill];
}

class NavTabChanged extends HomeEvent {
  final int index;
  const NavTabChanged(this.index);

  @override
  List<Object?> get props => [index];
}
