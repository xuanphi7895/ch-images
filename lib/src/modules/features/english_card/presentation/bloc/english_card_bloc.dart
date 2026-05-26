import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/english_card_repository.dart';
import 'english_card_event.dart';
import 'english_card_state.dart';

class EnglishCardBloc extends Bloc<EnglishCardEvent, EnglishCardState> {
  EnglishCardBloc({required EnglishCardRepository repository})
      : _repository = repository,
        super(const EnglishCardInitial()) {
    on<EnglishCardsLoadRequested>(_onLoad);
    on<EnglishCardNextPressed>(_onNext);
    on<EnglishCardPreviousPressed>(_onPrevious);
    on<EnglishCardFlipToggled>(_onFlip);
    on<EnglishCardFavoriteToggled>(_onFavorite);
  }

  final EnglishCardRepository _repository;

  Future<void> _onLoad(
    EnglishCardsLoadRequested event,
    Emitter<EnglishCardState> emit,
  ) async {
    emit(const EnglishCardLoading());
    try {
      final cards = await _repository.fetchCards();
      emit(EnglishCardsLoaded(cards: cards, currentIndex: 0, showBack: false));
    } catch (e) {
      emit(EnglishCardError(e.toString()));
    }
  }

  void _onNext(EnglishCardNextPressed event, Emitter<EnglishCardState> emit) {
    final s = state;
    if (s is! EnglishCardsLoaded || s.cards.isEmpty) return;
    final next = (s.currentIndex + 1) % s.cards.length;
    emit(s.copyWith(currentIndex: next, showBack: false));
  }

  void _onPrevious(
    EnglishCardPreviousPressed event,
    Emitter<EnglishCardState> emit,
  ) {
    final s = state;
    if (s is! EnglishCardsLoaded || s.cards.isEmpty) return;
    final prev = (s.currentIndex - 1 + s.cards.length) % s.cards.length;
    emit(s.copyWith(currentIndex: prev, showBack: false));
  }

  void _onFlip(EnglishCardFlipToggled event, Emitter<EnglishCardState> emit) {
    final s = state;
    if (s is! EnglishCardsLoaded) return;
    emit(s.copyWith(showBack: !s.showBack));
  }

  void _onFavorite(
    EnglishCardFavoriteToggled event,
    Emitter<EnglishCardState> emit,
  ) {
    final s = state;
    if (s is! EnglishCardsLoaded) return;

    final updated = s.cards.map((c) {
      if (c.id == s.current.id) {
        return c.copyWith(isFavorite: !c.isFavorite);
      }
      return c;
    }).toList();

    emit(s.copyWith(cards: updated));
  }
}
