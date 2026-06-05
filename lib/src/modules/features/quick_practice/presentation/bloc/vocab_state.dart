import 'package:equatable/equatable.dart';
import 'package:images/src/modules/features/quick_practice/domain/vocabulary.dart';
import 'package:images/src/utils/enum.dart';

abstract class VocabState extends Equatable {
  const VocabState();
  @override
  List<Object?> get props => [];
}

class VocabInitial extends VocabState {
  const VocabInitial();
}

class VocabLoading extends VocabState {
  const VocabLoading();
}

class VocabCardVisible extends VocabState {
  final VocabCard card;
  final int currentIndex;
  final int totalCards;
  final bool isRevealed;
  final Map<String, CardRating> ratings; // cardId → rating

  const VocabCardVisible({
    required this.card,
    required this.currentIndex,
    required this.totalCards,
    required this.isRevealed,
    required this.ratings,
  });

  VocabCardVisible copyWith({
    VocabCard? card,
    int? currentIndex,
    bool? isRevealed,
    Map<String, CardRating>? ratings,
  }) {
    return VocabCardVisible(
      card: card ?? this.card,
      currentIndex: currentIndex ?? this.currentIndex,
      totalCards: totalCards,
      isRevealed: isRevealed ?? this.isRevealed,
      ratings: ratings ?? this.ratings,
    );
  }

  double get progress => (currentIndex + 1) / totalCards;

  @override
  List<Object?> get props => [
    card,
    currentIndex,
    totalCards,
    isRevealed,
    ratings,
  ];
}

class VocabSessionDone extends VocabState {
  final Map<String, CardRating> ratings;
  final List<VocabCard> cards;

  const VocabSessionDone({required this.ratings, required this.cards});

  int get easyCount => ratings.values.where((r) => r == CardRating.easy).length;
  int get hardCount => ratings.values.where((r) => r == CardRating.hard).length;
  int get againCount =>
      ratings.values.where((r) => r == CardRating.again).length;

  int get xpEarned => easyCount * 3 + hardCount * 1;
  int get accuracyPercent =>
      cards.isEmpty ? 0 : ((easyCount / cards.length) * 100).round();

  @override
  List<Object?> get props => [ratings, cards];
}
