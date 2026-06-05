import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/home/domain/lesson_model.dart';
import 'package:images/src/modules/home/domain/quick_practice_model.dart';
import 'package:images/src/modules/home/domain/user_stats_model.dart';
import 'package:images/src/modules/home/presentation/bloc/home_event.dart';
import 'package:images/src/modules/home/presentation/bloc/home_state.dart';
import 'package:images/src/utils/enum.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<HomeLoaded>(_onHomeLoaded);
    on<LessonResumed>(_onLessonResumed);
    on<QuickPracticeTapped>(_onQuickPracticeTapped);
    on<NavTabChanged>(_onNavTabChanged);
  }

  Future<void> _onHomeLoaded(HomeLoaded event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());

    // Simulate network/DB fetch
    await Future.delayed(const Duration(milliseconds: 800));

    const stats = UserStats(
      name: 'Nguyen Linh',
      streakDays: 12,
      weeklyXp: 340,
      level: 'B1',
      dailyGoalMinutes: 25,
      completedMinutes: 15,
    );

    const lessons = [
      Lesson(
        id: 'l1',
        title: 'Listening: At the Airport',
        unit: 'Unit 3',
        type: LessonType.listening,
        progress: 0.45,
        levelTag: 'B1',
        minutesLeft: 8,
      ),
      Lesson(
        id: 'l2',
        title: 'Speaking: Job Interview',
        unit: 'Unit 5',
        type: LessonType.speaking,
        progress: 0.0,
        levelTag: 'B1',
        isNew: true,
        minutesLeft: 15,
      ),
    ];

    const quickPractices = [
      QuickPractice(
        id: 'q1',
        title: 'Vocabulary',
        subtitle: '24 cards due',
        skill: SkillType.vocabulary,
      ),
      QuickPractice(
        id: 'q2',
        title: 'Grammar',
        subtitle: 'Past perfect',
        skill: SkillType.grammar,
      ),
      QuickPractice(
        id: 'q3',
        title: 'Reading',
        subtitle: '2 articles',
        skill: SkillType.reading,
      ),
      QuickPractice(
        id: 'q4',
        title: 'Pronunciation',
        subtitle: 'Vowel sounds',
        skill: SkillType.pronunciation,
      ),
    ];

    emit(
      const HomeReady(
        stats: stats,
        lessons: lessons,
        quickPractices: quickPractices,
      ),
    );
  }

  void _onLessonResumed(LessonResumed event, Emitter<HomeState> emit) {
    // Navigate to lesson — handled in UI via BlocListener
    debugPrint('Resume lesson: ${event.lessonId}');
  }

  void _onQuickPracticeTapped(
    QuickPracticeTapped event,
    Emitter<HomeState> emit,
  ) {
    final currentState = state;
    emit(HomeNavigateToQuickPracticeScreen(event.skill));

    // Re-emit the previous HomeReady state so the Home Screen
    // stays rendered in the background and is visible when we return.
    if (currentState is HomeReady) {
      emit(currentState);
    }
  }

  void _onNavTabChanged(NavTabChanged event, Emitter<HomeState> emit) {
    if (state is HomeReady) {
      emit((state as HomeReady).copyWith(selectedNavIndex: event.index));
    }
  }
}
