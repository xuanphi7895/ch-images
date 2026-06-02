import 'package:flutter_tts/flutter_tts.dart';

// All screens -> same TtsService -> same FlutterTts

// Flow visualization

//App start
//   ↓
//_create _instance once
//   ↓
//TtsService()
//   ↓
//returns same _instance
//   ↓
//use same _tts

class TtsService {
  static final TtsService _instance =
      TtsService._internal(); // -> create one object only, shared globally (calls private constructor. This runs once.)

  factory TtsService() =>
      _instance; // -> With factory (same object returned): when you call TtsService(), it checks if _instance already exists. If it does, it returns that existing instance instead of creating a new one. This ensures that only one instance of TtsService is ever created and used throughout the app.

  TtsService._internal(); // -> private named constructor, can only be called from within the class. This prevents external code from creating new instances of TtsService, enforcing the singleton pattern.

  final FlutterTts _tts =
      FlutterTts(); // -> Because singleton: only one FlutterTts instance, shared across the app. avoids multiple engines running, avoids overlapping voices.

  Future<void> init() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}

// Why use Singleton here?

//Because TTS is usually:
// * global service
// * shared by many screens
// * only need one instance

//Good fit for:
// * Logger
// * Database connection
// * API client
// * Cache
// * TTS service
