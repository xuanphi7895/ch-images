// ═══════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════

import 'package:equatable/equatable.dart';

abstract class ReadingEvent extends Equatable {
  const ReadingEvent();
  @override
  List<Object?> get props => [];
}

class ReadingLoaded extends ReadingEvent {
  final String articleId;
  const ReadingLoaded(this.articleId);
  @override
  List<Object?> get props => [articleId];
}

class ReadingScrolled extends ReadingEvent {
  final int percent; // 0–100
  const ReadingScrolled(this.percent);
  @override
  List<Object?> get props => [percent];
}

class ReadingWordTapped extends ReadingEvent {
  final String word;
  const ReadingWordTapped(this.word);
  @override
  List<Object?> get props => [word];
}

class ReadingVocabDismissed extends ReadingEvent {
  const ReadingVocabDismissed();
}

class ReadingQuizStarted extends ReadingEvent {
  const ReadingQuizStarted();
}

class ReadingAnswerSelected extends ReadingEvent {
  final String questionId;
  final int selectedIndex;
  const ReadingAnswerSelected(this.questionId, this.selectedIndex);
  @override
  List<Object?> get props => [questionId, selectedIndex];
}

class ReadingNextQuestion extends ReadingEvent {
  const ReadingNextQuestion();
}

class ReadingCompleted extends ReadingEvent {
  const ReadingCompleted();
}

class ReadingRestarted extends ReadingEvent {
  const ReadingRestarted();
}

class ReadingFontSizeChanged extends ReadingEvent {
  final double fontSize;
  const ReadingFontSizeChanged(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}
