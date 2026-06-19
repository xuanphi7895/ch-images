// audio_helpers.dart
// Mic  → PCM 16-bit 16 kHz mono → Gemini Live
// Gemini Live → PCM 16-bit 24 kHz mono → Speaker
//
// packages:
//   record: ^5.1.2
//   just_audio: ^0.9.40         ← back to just_audio, more stable
//   path_provider: ^2.1.0

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

// ─────────────────────────────────────────────────────
// MIC RECORDER
// Streams raw PCM 16 kHz 16-bit mono chunks
// ─────────────────────────────────────────────────────

class MicRecorder {
  final _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _sub;
  final _ctrl = StreamController<Uint8List>.broadcast();

  Stream<Uint8List> get chunks => _ctrl.stream;

  Future<void> start() async {
    final ok = await _recorder.hasPermission();
    if (!ok) throw Exception('Microphone permission denied');

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000, // Gemini Live input must be 16 kHz
        numChannels: 1,
      ),
    );

    _sub = stream.listen(_ctrl.add, onError: _ctrl.addError);
  }

  Future<void> stop() async {
    await _sub?.cancel();
    await _recorder.stop();
  }

  void dispose() {
    _sub?.cancel();
    _ctrl.close();
    _recorder.dispose();
  }
}

// ─────────────────────────────────────────────────────
// PCM PLAYER
// Accumulates PCM chunks → writes a WAV file → plays it.
// We use a write-ahead buffer: collect ~0.5s of audio before
// playing so there are no glitches from tiny chunks.
// ─────────────────────────────────────────────────────

class PcmPlayer {
  static const int _sampleRate = 24000; // Gemini Live output
  static const int _channels = 1;
  static const int _bitsPerSample = 16;

  final AudioPlayer _player = AudioPlayer();

  // Accumulate chunks here during a turn
  final _buffer = BytesBuilder();
  bool _isPlaying = false;

  Future<void> init() async {
    await FlutterPcmSound.setup(sampleRate: 44100, channelCount: 1);
    // _player.(stream);
  }

  // ── Feed a PCM chunk from Gemini ──────────────────
  // Call this every time you receive a LiveApiAudioChunk.
  void feedChunk(Uint8List pcmBytes) {
    if (pcmBytes.isEmpty) return;
    _buffer.add(pcmBytes);
  }

  // ── Call this when Gemini signals turn complete ───
  // Writes the accumulated PCM to a WAV file and plays it.
  Future<void> playBuffered() async {
    if (_buffer.isEmpty) return;
    if (_isPlaying) {
      await _player.stop();
    }

    final pcmBytes = _buffer.takeBytes(); // empties the buffer
    final wavBytes = _wrapInWav(pcmBytes);

    // Write to a temp file — just_audio needs a file or URL
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/gemini_live_audio.wav');
    await file.writeAsBytes(wavBytes, flush: true);

    _isPlaying = true;
    await _player.setFilePath(file.path);
    await _player.play();
    _isPlaying = false;
  }

  // ── Stop immediately ──────────────────────────────
  Future<void> stop() async {
    _buffer.clear();
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> dispose() async {
    await stop();
    _player.dispose();
  }

  // ── Build WAV header + PCM data ───────────────────
  // Standard 44-byte WAV header (PCM, little-endian)
  static Uint8List _wrapInWav(Uint8List pcm) {
    final dataLen = pcm.length;
    final byteRate = _sampleRate * _channels * (_bitsPerSample ~/ 8);
    final blockAlign = _channels * (_bitsPerSample ~/ 8);

    final header = ByteData(44);
    void setStr(int offset, String s) {
      for (var i = 0; i < s.length; i++) {
        header.setUint8(offset + i, s.codeUnitAt(i));
      }
    }

    setStr(0, 'RIFF');
    header.setUint32(4, 36 + dataLen, Endian.little); // file size - 8
    setStr(8, 'WAVE');
    setStr(12, 'fmt ');
    header.setUint32(16, 16, Endian.little); // chunk size
    header.setUint16(20, 1, Endian.little); // PCM = 1
    header.setUint16(22, _channels, Endian.little);
    header.setUint32(24, _sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, _bitsPerSample, Endian.little);
    setStr(36, 'data');
    header.setUint32(40, dataLen, Endian.little);

    // Combine header + PCM
    final wav = Uint8List(44 + dataLen);
    wav.setRange(0, 44, header.buffer.asUint8List());
    wav.setRange(44, 44 + dataLen, pcm);
    return wav;
  }
}
