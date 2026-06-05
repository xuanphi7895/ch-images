import 'package:equatable/equatable.dart';
import 'package:images/src/modules/home/domain/lesson_model.dart';
import 'package:images/src/modules/home/domain/quick_practice_model.dart';
import 'package:images/src/modules/home/domain/user_stats_model.dart';
import 'package:images/src/utils/enum.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeReady extends HomeState {
  final UserStats stats;
  final List<Lesson> lessons;
  final List<QuickPractice> quickPractices;
  final int selectedNavIndex;

  const HomeReady({
    required this.stats,
    required this.lessons,
    required this.quickPractices,
    this.selectedNavIndex = 0,
  });

  HomeReady copyWith({
    UserStats? stats,
    List<Lesson>? lessons,
    List<QuickPractice>? quickPractices,
    int? selectedNavIndex,
  }) {
    return HomeReady(
      stats: stats ?? this.stats,
      lessons: lessons ?? this.lessons,
      quickPractices: quickPractices ?? this.quickPractices,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
    );
  }

  @override
  List<Object?> get props => [stats, lessons, quickPractices, selectedNavIndex];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeNavigateToQuickPracticeScreen extends HomeState {
  const HomeNavigateToQuickPracticeScreen(this.skillType);
  final SkillType skillType;

  @override
  List<Object> get props => [skillType];
}
