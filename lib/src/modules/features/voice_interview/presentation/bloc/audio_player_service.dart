import 'dart:io';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playBytes(
    Uint8List audioBytes, {
    String extension = 'wav',
  }) async {
    final tempDir = await getTemporaryDirectory();

    final file = File('${tempDir.path}/gemini_response.$extension');

    await file.writeAsBytes(audioBytes, flush: true);

    await _player.setFilePath(file.path);

    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  Future<void> playAudioBytes(Uint8List bytes) async {
    // save temp file
    // play with just_audio
  }
}
