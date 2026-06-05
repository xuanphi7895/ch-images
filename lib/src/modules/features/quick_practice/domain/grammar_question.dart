import 'package:equatable/equatable.dart';

class GrammarQuestion extends Equatable {
  final String id;
  final String category;
  final String sentence;
  final String blankWord;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const GrammarQuestion({
    required this.id,
    required this.category,
    required this.sentence,
    required this.blankWord,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  String get correctAnswer => options[correctIndex];

  @override
  List<Object?> get props => [
    id,
    category,
    sentence,
    blankWord,
    options,
    correctIndex,
    explanation,
  ];
}
