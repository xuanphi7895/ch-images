import 'package:equatable/equatable.dart';

class VocabCard extends Equatable {
  final String id;
  final String word;
  final String ipa;
  final String meaning;
  final String exampleSentence;
  final int reviewIntervalDays;

  const VocabCard({
    required this.id,
    required this.word,
    required this.ipa,
    required this.meaning,
    required this.exampleSentence,
    required this.reviewIntervalDays,
  });

  VocabCard withInterval(int days) => VocabCard(
    id: id,
    word: word,
    ipa: ipa,
    meaning: meaning,
    exampleSentence: exampleSentence,
    reviewIntervalDays: days,
  );

  @override
  List<Object?> get props => [
    id,
    word,
    ipa,
    meaning,
    exampleSentence,
    reviewIntervalDays,
  ];
}
