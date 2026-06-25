// reading_models.dart

import 'package:equatable/equatable.dart';

// ─── Enums ────────────────────────────────────────────

enum ReadingDifficulty { easy, medium, hard }

enum QuestionType { multipleChoice, trueFalse, fillBlank }

// ─── Article model ────────────────────────────────────

class ReadingArticle extends Equatable {
  final String id;
  final String title;
  final String topic; // e.g. "Technology"
  final String imageUrl;
  final String content; // full article text (paragraphs separated by \n\n)
  final ReadingDifficulty difficulty;
  final int estimatedMinutes;
  final int wordCount;
  final List<VocabWord> vocabWords;
  final List<ReadingQuestion> questions;
  final int xpReward;

  const ReadingArticle({
    required this.id,
    required this.title,
    required this.topic,
    required this.imageUrl,
    required this.content,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.wordCount,
    required this.vocabWords,
    required this.questions,
    required this.xpReward,
  });

  List<String> get paragraphs =>
      content.split('\n\n').where((p) => p.trim().isNotEmpty).toList();

  @override
  List<Object?> get props => [id, title, topic];
}

class VocabWord extends Equatable {
  final String word;
  final String definition;
  final String exampleSentence;
  final String partOfSpeech; // noun, verb, adjective…

  const VocabWord({
    required this.word,
    required this.definition,
    required this.exampleSentence,
    required this.partOfSpeech,
  });

  @override
  List<Object?> get props => [word];
}

class ReadingQuestion extends Equatable {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options; // for multipleChoice
  final int correctIndex; // index into options
  final String explanation;

  const ReadingQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  String get correctAnswer => options[correctIndex];

  @override
  List<Object?> get props => [id, question];
}

// ─── Session progress ─────────────────────────────────

class ReadingSession extends Equatable {
  final String articleId;
  final int currentParagraph; // index of paragraph being read
  final Set<String> highlightedWordIds;
  final Map<String, int> answers; // questionId → selected index
  final bool quizStarted;
  final bool completed;
  final int scrollPercent; // 0–100

  const ReadingSession({
    required this.articleId,
    required this.currentParagraph,
    required this.highlightedWordIds,
    required this.answers,
    required this.quizStarted,
    required this.completed,
    required this.scrollPercent,
  });

  bool get allAnswered => answers.length >= 0;
  int get correctCount => 0; // calculated in BLoC

  ReadingSession copyWith({
    int? currentParagraph,
    Set<String>? highlightedWordIds,
    Map<String, int>? answers,
    bool? quizStarted,
    bool? completed,
    int? scrollPercent,
  }) {
    return ReadingSession(
      articleId: articleId,
      currentParagraph: currentParagraph ?? this.currentParagraph,
      highlightedWordIds: highlightedWordIds ?? this.highlightedWordIds,
      answers: answers ?? this.answers,
      quizStarted: quizStarted ?? this.quizStarted,
      completed: completed ?? this.completed,
      scrollPercent: scrollPercent ?? this.scrollPercent,
    );
  }

  @override
  List<Object?> get props => [
    articleId,
    currentParagraph,
    highlightedWordIds,
    answers,
    quizStarted,
    completed,
    scrollPercent,
  ];
}
