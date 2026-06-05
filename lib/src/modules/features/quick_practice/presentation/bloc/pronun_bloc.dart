import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/quick_practice/domain/pronun_word.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/pronun_event.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/pronun_state.dart';
import 'package:images/src/utils/enum.dart';

class PronunBloc extends Bloc<PronunEvent, PronunState> {
  static const _mockWords = [
    PronunWord(
      id: 'p1',
      word: 'through',
      ipa: '/θruː/',
      audioAssetPath: 'assets/audio/through.mp3',
    ),
    PronunWord(
      id: 'p2',
      word: 'thought',
      ipa: '/θɔːt/',
      audioAssetPath: 'assets/audio/thought.mp3',
    ),
    PronunWord(
      id: 'p3',
      word: 'thoroughly',
      ipa: '/ˈθʌr.ə.li/',
      audioAssetPath: 'assets/audio/thoroughly.mp3',
    ),
  ];

  PronunBloc() : super(const PronunInitial()) {
    on<PronunStarted>(_onStarted);
    on<PronunPlaybackRequested>(_onPlayback);
    on<PronunRecordingStarted>(_onRecordingStarted);
    on<PronunRecordingSubmitted>(_onRecordingSubmitted);
    on<PronunNextWord>(_onNextWord);
  }

  Future<void> _onStarted(
    PronunStarted event,
    Emitter<PronunState> emit,
  ) async {
    emit(const PronunLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    emit(
      PronunWordVisible(
        word: _mockWords.first,
        currentIndex: 0,
        totalWords: _mockWords.length,
        status: RecordingStatus.idle,
        scores: const [],
      ),
    );
  }

  Future<void> _onPlayback(
    PronunPlaybackRequested event,
    Emitter<PronunState> emit,
  ) async {
    if (state is! PronunWordVisible) return;
    final s = state as PronunWordVisible;

    emit(s.copyWith(status: RecordingStatus.playing));
    // TODO: play s.word.audioAssetPath via audioplayers package
    await Future.delayed(const Duration(milliseconds: 1200));
    emit(s.copyWith(status: RecordingStatus.idle));
  }

  void _onRecordingStarted(
    PronunRecordingStarted event,
    Emitter<PronunState> emit,
  ) {
    if (state is! PronunWordVisible) return;
    // TODO: start microphone via flutter_sound or record package
    emit(
      (state as PronunWordVisible).copyWith(status: RecordingStatus.recording),
    );
  }

  Future<void> _onRecordingSubmitted(
    PronunRecordingSubmitted event,
    Emitter<PronunState> emit,
  ) async {
    if (state is! PronunWordVisible) return;
    final s = state as PronunWordVisible;

    emit(s.copyWith(status: RecordingStatus.analyzing));

    // TODO: send event.recordingPath to speech scoring API
    // (Azure Pronunciation Assessment or Google Speech-to-Text)
    await Future.delayed(const Duration(milliseconds: 1500));

    // Simulated score — replace with real API response
    const result = PronunResult(
      scorePercent: 84,
      tip: 'Hold the "oo" sound a little longer.',
    );

    emit(s.copyWith(status: RecordingStatus.result, result: result));
  }

  void _onNextWord(PronunNextWord event, Emitter<PronunState> emit) {
    if (state is! PronunWordVisible) return;
    final s = state as PronunWordVisible;

    final updatedScores = [
      ...s.scores,
      if (s.result != null) s.result!.scorePercent,
    ];

    final nextIndex = s.currentIndex + 1;
    if (nextIndex >= _mockWords.length) {
      final avg = updatedScores.isEmpty
          ? 0
          : (updatedScores.reduce((a, b) => a + b) / updatedScores.length)
                .round();
      emit(
        PronunSessionDone(
          averageScore: avg,
          totalWords: s.totalWords,
          durationSeconds: 0, // track via session timer if needed
        ),
      );
      return;
    }

    emit(
      PronunWordVisible(
        word: _mockWords[nextIndex],
        currentIndex: nextIndex,
        totalWords: s.totalWords,
        status: RecordingStatus.idle,
        scores: updatedScores,
      ),
    );
  }
}
