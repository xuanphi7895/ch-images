import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

class DictionaryAudio {
  DictionaryAudio() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45);
  }

  final _player = AudioPlayer();
  final _tts = FlutterTts();
  bool _busy = false;

  bool get isBusy => _busy;

  Future<void> playWord({String? audioUrl, required String word}) async {
    _busy = true;
    try {
      await _player.stop();
      await _tts.stop();

      if (audioUrl != null && audioUrl.trim().isNotEmpty) {
        await _player.setUrl(audioUrl);
        await _player.play();
      } else {
        await _tts.speak(word);
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> speakExample(String text) async {
    _busy = true;
    try {
      await _player.stop();
      await _tts.stop();
      await _tts.speak(text);
    } finally {
      _busy = false;
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
