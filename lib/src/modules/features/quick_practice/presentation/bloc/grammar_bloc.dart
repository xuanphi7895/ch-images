import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/quick_practice/domain/grammar_question.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/grammar_event.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/grammar_state.dart';
import 'dart:async';

class GrammarBloc extends Bloc<GrammarEvent, GrammarState> {
  StreamSubscription<int>? _timerSub;

  static const _mockQuestions = [
    GrammarQuestion(
      id: 'g1',
      category: 'Past perfect',
      sentence: 'By the time she arrived, he ___ the building.',
      blankWord: 'had already left',
      options: [
        'has already left',
        'had already left',
        'already left',
        'was already leaving',
      ],
      correctIndex: 1,
      explanation:
          'Past perfect (had + past participle) is used for actions completed before another past action.',
    ),
    GrammarQuestion(
      id: 'g2',
      category: 'Conditional',
      sentence: 'If I ___ more time, I would travel the world.',
      blankWord: 'had',
      options: ['have', 'had', 'has', 'would have'],
      correctIndex: 1,
      explanation:
          'Second conditional uses "if + past simple" to describe hypothetical situations.',
    ),
    GrammarQuestion(
      id: 'g3',
      category: 'Passive voice',
      sentence: 'The report ___ by the manager yesterday.',
      blankWord: 'was written',
      options: ['written', 'was written', 'has written', 'wrote'],
      correctIndex: 1,
      explanation:
          'Passive voice: was/were + past participle. "Written" is the past participle of "write".',
    ),
  ];

  GrammarBloc() : super(const GrammarInitial()) {
    on<GrammarStarted>(_onStarted);
    on<GrammarOptionSelected>(_onOptionSelected);
    on<GrammarNextQuestion>(_onNextQuestion);
    on<GrammarTimerTicked>(_onTimerTicked);
  }

  Future<void> _onStarted(
    GrammarStarted event,
    Emitter<GrammarState> emit,
  ) async {
    emit(const GrammarLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    _startTimer();
    emit(
      GrammarQuestionVisible(
        question: _mockQuestions.first,
        currentIndex: 0,
        totalQuestions: _mockQuestions.length,
        elapsedSeconds: 0,
        correctCount: 0,
      ),
    );
  }

  void _onOptionSelected(
    GrammarOptionSelected event,
    Emitter<GrammarState> emit,
  ) {
    if (state is! GrammarQuestionVisible) return;
    final s = state as GrammarQuestionVisible;
    if (s.isAnswered) return;

    final isCorrect = event.selectedIndex == s.question.correctIndex;
    emit(
      s.copyWith(
        selectedIndex: event.selectedIndex,
        isAnswered: true,
        correctCount: isCorrect ? s.correctCount + 1 : s.correctCount,
      ),
    );
  }

  void _onNextQuestion(GrammarNextQuestion event, Emitter<GrammarState> emit) {
    if (state is! GrammarQuestionVisible) return;
    final s = state as GrammarQuestionVisible;

    final nextIndex = s.currentIndex + 1;
    if (nextIndex >= _mockQuestions.length) {
      _timerSub?.cancel();
      emit(
        GrammarSessionDone(
          correctCount: s.correctCount,
          totalQuestions: s.totalQuestions,
          durationSeconds: s.elapsedSeconds,
        ),
      );
      return;
    }

    emit(
      GrammarQuestionVisible(
        question: _mockQuestions[nextIndex],
        currentIndex: nextIndex,
        totalQuestions: s.totalQuestions,
        elapsedSeconds: s.elapsedSeconds,
        correctCount: s.correctCount,
      ),
    );
  }

  void _onTimerTicked(GrammarTimerTicked event, Emitter<GrammarState> emit) {
    if (state is GrammarQuestionVisible) {
      emit(
        (state as GrammarQuestionVisible).copyWith(
          elapsedSeconds: event.elapsed,
        ),
      );
    }
  }

  void _startTimer() {
    int elapsed = 0;
    _timerSub = Stream.periodic(
      const Duration(seconds: 1),
      (_) => ++elapsed,
    ).listen((tick) => add(GrammarTimerTicked(tick)));
  }

  @override
  Future<void> close() {
    _timerSub?.cancel();
    return super.close();
  }
}
