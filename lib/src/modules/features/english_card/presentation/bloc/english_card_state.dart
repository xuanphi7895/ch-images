import 'package:equatable/equatable.dart';

import '../../domain/english_card_model.dart';

abstract class EnglishCardState extends Equatable {
  const EnglishCardState();

  @override
  List<Object?> get props => [];
}

class EnglishCardInitial extends EnglishCardState {
  const EnglishCardInitial();
}

class EnglishCardLoading extends EnglishCardState {
  const EnglishCardLoading();
}

class EnglishCardsLoaded extends EnglishCardState {
  const EnglishCardsLoaded({
    required this.cards,
    required this.currentIndex,
    required this.showBack,
  });

  final List<EnglishCardModel> cards;
  final int currentIndex;
  final bool showBack;

  EnglishCardModel get current => cards[currentIndex];

  EnglishCardsLoaded copyWith({
    List<EnglishCardModel>? cards,
    int? currentIndex,
    bool? showBack,
  }) {
    return EnglishCardsLoaded(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      showBack: showBack ?? this.showBack,
    );
  }

  @override
  List<Object?> get props => [cards, currentIndex, showBack];
}

class EnglishCardError extends EnglishCardState {
  const EnglishCardError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
