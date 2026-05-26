import 'package:equatable/equatable.dart';

class EnglishCardModel extends Equatable {
  const EnglishCardModel({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.partOfSpeech,
    required this.definition,
    required this.example,
    required this.level,
    this.isFavorite = false,
  });

  final String id;
  final String word;
  final String phonetic;
  final String partOfSpeech;
  final String definition;
  final String example;
  final String level;
  final bool isFavorite;

  EnglishCardModel copyWith({bool? isFavorite}) {
    return EnglishCardModel(
      id: id,
      word: word,
      phonetic: phonetic,
      partOfSpeech: partOfSpeech,
      definition: definition,
      example: example,
      level: level,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        word,
        phonetic,
        partOfSpeech,
        definition,
        example,
        level,
        isFavorite,
      ];
}
