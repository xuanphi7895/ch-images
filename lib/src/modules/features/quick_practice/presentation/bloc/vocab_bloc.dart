import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/quick_practice/domain/vocabulary.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/vocab_event.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/vocab_state.dart';
import 'package:images/src/utils/enum.dart';

class VocabBloc extends Bloc<VocabEvent, VocabState> {
  // Simulated card deck — replace with repository call
  static const _mockCards = [
    VocabCard(
      id: 'v1',
      word: 'Eloquent',
      ipa: '/ˈɛl.ə.kwənt/',
      meaning: 'Fluent or persuasive in speaking or writing.',
      exampleSentence: 'She gave an eloquent speech.',
      reviewIntervalDays: 1,
    ),
    VocabCard(
      id: 'v2',
      word: 'Persevere',
      ipa: '/ˌpɜː.sɪˈvɪər/',
      meaning: 'Continue in a course of action despite difficulty.',
      exampleSentence: 'He persevered through the tough training.',
      reviewIntervalDays: 1,
    ),
    VocabCard(
      id: 'v3',
      word: 'Ambiguous',
      ipa: '/æmˈbɪɡ.ju.əs/',
      meaning: 'Open to more than one interpretation.',
      exampleSentence: 'The contract contained ambiguous language.',
      reviewIntervalDays: 3,
    ),
  ];

  VocabBloc() : super(const VocabInitial()) {
    on<VocabStarted>(_onStarted);
    on<VocabAnswerRevealed>(_onRevealed);
    on<VocabCardRated>(_onRated);
  }

  Future<void> _onStarted(VocabStarted event, Emitter<VocabState> emit) async {
    emit(const VocabLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    emit(
      VocabCardVisible(
        card: _mockCards.first,
        currentIndex: 0,
        totalCards: _mockCards.length,
        isRevealed: false,
        ratings: const {},
      ),
    );
  }

  void _onRevealed(VocabAnswerRevealed event, Emitter<VocabState> emit) {
    if (state is VocabCardVisible) {
      emit((state as VocabCardVisible).copyWith(isRevealed: true));
    }
  }

  void _onRated(VocabCardRated event, Emitter<VocabState> emit) {
    if (state is! VocabCardVisible) return;
    final s = state as VocabCardVisible;

    final updatedRatings = Map<String, CardRating>.from(s.ratings)
      ..[s.card.id] = event.rating;

    final nextIndex = s.currentIndex + 1;

    if (nextIndex >= _mockCards.length) {
      emit(VocabSessionDone(ratings: updatedRatings, cards: _mockCards));
      return;
    }

    emit(
      VocabCardVisible(
        card: _mockCards[nextIndex],
        currentIndex: nextIndex,
        totalCards: s.totalCards,
        isRevealed: false,
        ratings: updatedRatings,
      ),
    );
  }
}
