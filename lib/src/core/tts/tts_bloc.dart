import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_event.dart';
import 'tts_state.dart';

class TtsBloc extends Bloc<TtsEvent, TtsState> {
  final FlutterTts _tts = FlutterTts();

  TtsBloc() : super(TtsState.initial()) {
    _init();

    on<SpeakTextEvent>(_onSpeak);
    on<ProgressChangedEvent>(_onProgress);
    on<StopTtsEvent>(_onStop);
  }

  Future<void> _init() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);

    _tts.setProgressHandler((text, start, end, word) {
      add(ProgressChangedEvent(start: start, end: end));
    });
  }

  Future<void> _onSpeak(SpeakTextEvent event, Emitter<TtsState> emit) async {
    emit(state.copyWith(text: event.text, isSpeaking: true, start: 0, end: 0));

    await _tts.stop();
    await _tts.speak(event.text);
  }

  void _onProgress(ProgressChangedEvent event, Emitter<TtsState> emit) {
    emit(state.copyWith(start: event.start, end: event.end));
  }

  Future<void> _onStop(StopTtsEvent event, Emitter<TtsState> emit) async {
    await _tts.stop();

    emit(state.copyWith(isSpeaking: false));
  }

  @override
  Future<void> close() {
    _tts.stop();
    return super.close();
  }
}
