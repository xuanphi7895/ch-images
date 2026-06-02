import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'speech_state.dart';

class SpeechBloc extends Bloc<dynamic, SpeechState> {
  SpeechBloc()
    : super(
        SpeechState(words: const [], currentIndex: null, isPlaying: false),
      ) {
    on<SpeechRequested>(_onRequested);
    on<SpeechProgressed>(_onProgressed);
    on<SpeechFinished>(_onFinished);
  }

  final _tts = FlutterTts();

  Future<void> _onRequested(
    SpeechRequested e,
    Emitter<SpeechState> emit,
  ) async {
    final parts = e.text.split(' ');
    emit(SpeechState(words: parts, currentIndex: null, isPlaying: true));

    // connect TTS progress callback → BLoC event
    _tts.setProgressHandler((text, start, end, word) {
      final idx = parts.indexWhere(
        (w) =>
            w.replaceAll(RegExp(r'[^\w]'), '') ==
            word.replaceAll(RegExp(r'[^\w]'), ''),
      );
      add(SpeechProgressed(idx == -1 ? null : idx));
    });

    _tts.setCompletionHandler(() => add(const SpeechFinished()));

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.stop();
    await _tts.speak(e.text);
  }

  void _onProgressed(SpeechProgressed e, Emitter<SpeechState> emit) {
    emit(state.copyWith(currentIndex: e.index));
  }

  void _onFinished(SpeechFinished e, Emitter<SpeechState> emit) {
    emit(state.copyWith(currentIndex: null, isPlaying: false));
  }
}
