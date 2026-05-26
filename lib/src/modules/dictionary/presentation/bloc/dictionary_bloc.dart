import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import 'package:images/src/modules/dictionary/presentation/bloc/dictionary_event.dart';
import 'package:images/src/modules/dictionary/data/dictionary_repository.dart';
import 'package:images/src/modules/dictionary/presentation/bloc/dictionary_state.dart';

class DictionaryBloc extends Bloc<DictionaryEvent, DictionaryState> {
  DictionaryBloc({required DictionaryRepository repository})
    : _repo = repository,
      super(const DictionaryInitial()) {
    on<DictionaryLoadRequested>(_onLoadRequested);
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45); // tune for clarity
  }

  final DictionaryRepository _repo;
  final _player = AudioPlayer();
  final _tts = FlutterTts();

  Future<void> _onLoadRequested(
    DictionaryLoadRequested event,
    Emitter<DictionaryState> emit,
  ) async {
    emit(const DictionaryLoading());
    try {
      final data = await _repo.fetchEntry(event.word);
      emit(DictionaryLoaded(data));
    } catch (e) {
      emit(DictionaryError(e.toString()));
    }
  }

  Future<void> playWordFromUrl(String url) async {
    await _player.stop();
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> speak(String text) async {
    await _player.stop(); // avoid talking over MP3
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
