// ─── States ───────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:images/src/modules/features/quick_practice/domain/pronun_word.dart';
import 'package:images/src/utils/enum.dart';

abstract class PronunState extends Equatable {
  const PronunState();
  @override
  List<Object?> get props => [];
}

class PronunInitial extends PronunState {
  const PronunInitial();
}

class PronunLoading extends PronunState {
  const PronunLoading();
}

class PronunWordVisible extends PronunState {
  final PronunWord word;
  final int currentIndex;
  final int totalWords;
  final RecordingStatus status;
  final PronunResult? result;
  final List<int> scores; // score per completed word

  const PronunWordVisible({
    required this.word,
    required this.currentIndex,
    required this.totalWords,
    required this.status,
    required this.scores,
    this.result,
  });

  double get progress => (currentIndex + 1) / totalWords;
  int get averageScore => scores.isEmpty
      ? 0
      : (scores.reduce((a, b) => a + b) / scores.length).round();

  PronunWordVisible copyWith({
    RecordingStatus? status,
    PronunResult? result,
    List<int>? scores,
  }) {
    return PronunWordVisible(
      word: word,
      currentIndex: currentIndex,
      totalWords: totalWords,
      status: status ?? this.status,
      result: result ?? this.result,
      scores: scores ?? this.scores,
    );
  }

  @override
  List<Object?> get props => [
    word,
    currentIndex,
    totalWords,
    status,
    result,
    scores,
  ];
}

class PronunSessionDone extends PronunState {
  final int averageScore;
  final int totalWords;
  final int durationSeconds;

  const PronunSessionDone({
    required this.averageScore,
    required this.totalWords,
    required this.durationSeconds,
  });

  int get xpEarned => (averageScore / 10).round() * 2;
  int get accuracyPercent => averageScore;

  @override
  List<Object?> get props => [averageScore, totalWords, durationSeconds];
}
