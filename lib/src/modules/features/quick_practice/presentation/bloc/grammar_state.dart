// ─── States ───────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:images/src/modules/features/quick_practice/domain/grammar_question.dart';

abstract class GrammarState extends Equatable {
  const GrammarState();
  @override
  List<Object?> get props => [];
}

class GrammarInitial extends GrammarState {
  const GrammarInitial();
}

class GrammarLoading extends GrammarState {
  const GrammarLoading();
}

class GrammarQuestionVisible extends GrammarState {
  final GrammarQuestion question;
  final int currentIndex;
  final int totalQuestions;
  final int? selectedIndex; // null = not answered yet
  final bool isAnswered;
  final int elapsedSeconds;
  final int correctCount;

  const GrammarQuestionVisible({
    required this.question,
    required this.currentIndex,
    required this.totalQuestions,
    required this.elapsedSeconds,
    required this.correctCount,
    this.selectedIndex,
    this.isAnswered = false,
  });

  double get progress => (currentIndex + 1) / totalQuestions;
  bool get isCorrect =>
      selectedIndex != null && selectedIndex == question.correctIndex;

  GrammarQuestionVisible copyWith({
    int? selectedIndex,
    bool? isAnswered,
    int? elapsedSeconds,
    int? correctCount,
  }) {
    return GrammarQuestionVisible(
      question: question,
      currentIndex: currentIndex,
      totalQuestions: totalQuestions,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isAnswered: isAnswered ?? this.isAnswered,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      correctCount: correctCount ?? this.correctCount,
    );
  }

  @override
  List<Object?> get props => [
    question,
    currentIndex,
    totalQuestions,
    selectedIndex,
    isAnswered,
    elapsedSeconds,
    correctCount,
  ];
}

class GrammarSessionDone extends GrammarState {
  final int correctCount;
  final int totalQuestions;
  final int durationSeconds;

  const GrammarSessionDone({
    required this.correctCount,
    required this.totalQuestions,
    required this.durationSeconds,
  });

  int get xpEarned => correctCount * 5;
  int get accuracyPercent =>
      totalQuestions == 0 ? 0 : ((correctCount / totalQuestions) * 100).round();

  @override
  List<Object?> get props => [correctCount, totalQuestions, durationSeconds];
}
