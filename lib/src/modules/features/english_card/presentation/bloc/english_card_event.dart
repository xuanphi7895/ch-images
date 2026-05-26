import 'package:equatable/equatable.dart';

abstract class EnglishCardEvent extends Equatable {
  const EnglishCardEvent();

  @override
  List<Object?> get props => [];
}

class EnglishCardsLoadRequested extends EnglishCardEvent {
  const EnglishCardsLoadRequested();
}

class EnglishCardNextPressed extends EnglishCardEvent {
  const EnglishCardNextPressed();
}

class EnglishCardPreviousPressed extends EnglishCardEvent {
  const EnglishCardPreviousPressed();
}

class EnglishCardFlipToggled extends EnglishCardEvent {
  const EnglishCardFlipToggled();
}

class EnglishCardFavoriteToggled extends EnglishCardEvent {
  const EnglishCardFavoriteToggled();
}
