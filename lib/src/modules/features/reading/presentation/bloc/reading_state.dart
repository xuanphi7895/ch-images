// reading_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:images/src/modules/features/reading/data/reading_models.dart';

// ═══════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════

abstract class ReadingState extends Equatable {
  const ReadingState();
  @override
  List<Object?> get props => [];
}

class ReadingInitial extends ReadingState {
  const ReadingInitial();
}

class ReadingLoading extends ReadingState {
  const ReadingLoading();
}

class ReadingReady extends ReadingState {
  final ReadingArticle article;
  final ReadingSession session;
  final VocabWord? activeVocabWord; // shown in bottom sheet
  final int currentQuestionIndex;
  final double fontSize; // 14–22
  final bool showTranslation;

  const ReadingReady({
    required this.article,
    required this.session,
    required this.fontSize,
    this.activeVocabWord,
    this.currentQuestionIndex = 0,
    this.showTranslation = false,
  });

  // Convenience getters
  ReadingQuestion? get currentQuestion =>
      session.quizStarted && currentQuestionIndex < article.questions.length
      ? article.questions[currentQuestionIndex]
      : null;

  bool get isLastQuestion =>
      currentQuestionIndex >= article.questions.length - 1;

  bool get currentQuestionAnswered =>
      currentQuestion != null &&
      session.answers.containsKey(currentQuestion!.id);

  int get correctCount => session.answers.entries.where((e) {
    final q = article.questions.firstWhere(
      (q) => q.id == e.key,
      orElse: () => article.questions.first,
    );
    return e.value == q.correctIndex;
  }).length;

  int get xpEarned =>
      (correctCount / article.questions.length * article.xpReward).round();

  ReadingReady copyWith({
    ReadingArticle? article,
    ReadingSession? session,
    VocabWord? activeVocabWord,
    int? currentQuestionIndex,
    double? fontSize,
    bool? showTranslation,
    bool clearVocab = false,
  }) {
    return ReadingReady(
      article: article ?? this.article,
      session: session ?? this.session,
      activeVocabWord: clearVocab
          ? null
          : activeVocabWord ?? this.activeVocabWord,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      fontSize: fontSize ?? this.fontSize,
      showTranslation: showTranslation ?? this.showTranslation,
    );
  }

  @override
  List<Object?> get props => [
    article,
    session,
    activeVocabWord,
    currentQuestionIndex,
    fontSize,
    showTranslation,
  ];
}

class ReadingFinished extends ReadingState {
  final ReadingArticle article;
  final int correctCount;
  final int totalQuestions;
  final int xpEarned;
  final int durationSeconds;

  const ReadingFinished({
    required this.article,
    required this.correctCount,
    required this.totalQuestions,
    required this.xpEarned,
    required this.durationSeconds,
  });

  int get accuracyPercent =>
      totalQuestions == 0 ? 0 : ((correctCount / totalQuestions) * 100).round();

  @override
  List<Object?> get props => [article, correctCount, totalQuestions, xpEarned];
}

class ReadingError extends ReadingState {
  final String message;
  const ReadingError(this.message);
  @override
  List<Object?> get props => [message];
}
