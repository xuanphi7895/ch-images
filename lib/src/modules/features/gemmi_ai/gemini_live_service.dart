// gemini_live_service.dart
// Gemini Live API — WebSocket connection
//
// Key fixes vs previous version:
//  1. Correct setup message with realtimeInputConfig (VAD)
//  2. Must wait for setupComplete before sending audio
//  3. Full debug logging so you can see every message
//  4. sendText uses realtimeInput not clientContent

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:io';

// ── WebSocket URL ─────────────────────────────────────
const _wsUrl =
    'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService/BidiGenerateContent';

// ─── Events ───────────────────────────────────────────

abstract class LiveApiEvent {}

class LiveApiConnected extends LiveApiEvent {}

class LiveApiSetupDone extends LiveApiEvent {} // ← NEW: setup confirmed

class LiveApiTurnComplete extends LiveApiEvent {}

class LiveApiDisconnected extends LiveApiEvent {
  final String? reason;
  LiveApiDisconnected({this.reason});
}

class LiveApiAudioChunk extends LiveApiEvent {
  final Uint8List pcmBytes;
  LiveApiAudioChunk(this.pcmBytes);
}

class LiveApiTranscript extends LiveApiEvent {
  final String text;
  final bool isUser;
  LiveApiTranscript({required this.text, required this.isUser});
}

class LiveApiError extends LiveApiEvent {
  final String message;
  LiveApiError(this.message);
}

// ─────────────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────────────

class GeminiLiveService {
  final String apiKey;
  final String model;
  final String systemPrompt;

  WebSocket? _channel;
  StreamController<LiveApiEvent>? _controller;
  StreamSubscription? _wsSub;

  bool _isConnected = false;
  bool _setupDone = false; // must be true before sending audio
  bool _enableDebug = true; // set false in production

  GeminiLiveService({
    required this.apiKey,
    this.model = 'gemini-2.5-flash-native-audio-preview-12-2025',
    this.systemPrompt = '',
  });

  Stream<LiveApiEvent> get events =>
      _controller?.stream ?? const Stream.empty();

  bool get isConnected => _isConnected;
  bool get isReady => _isConnected && _setupDone;

  void _log(String msg) {
    if (_enableDebug) debugPrint('[GeminiLive] $msg');
  }

  // ── Connect ────────────────────────────────────────

  Future<void> connect() async {
    if (_isConnected) return;
    _setupDone = false;

    _controller = StreamController<LiveApiEvent>.broadcast();

    // Build URL — keep as single string, no concatenation
    final wsUrl = '$_wsUrl?key=$apiKey';
    _log('Connecting to $wsUrl');

    try {
      // Use dart:io WebSocket directly — most reliable on Android + iOS
      _channel = await WebSocket.connect(
        wsUrl,
        headers: {'Content-Type': 'application/json'},
      );

      _log('WebSocket opened');
    } catch (e) {
      _log('Connect failed: $e');
      _controller?.add(LiveApiError('Connection failed: $e'));
      return;
    }

    _wsSub = _channel!.listen(
      _onMessage,
      onError: (e) {
        _log('WebSocket error: $e');
        _controller?.add(LiveApiError(e.toString()));
        _isConnected = false;
        _setupDone = false;
      },
      onDone: () {
        _log(
          'Closed code=${_channel?.closeCode} '
          'reason=${_channel?.closeReason}',
        );
        _isConnected = false;
        _setupDone = false;
        _controller?.add(LiveApiDisconnected());
      },
    );

    _isConnected = true;
    _controller?.add(LiveApiConnected());

    // ── Send setup — MUST be the very first message ──
    final setup = {
      'setup': {
        'model': 'models/$model',
        'generation_config': {
          'response_modalities': ['AUDIO'],
          'speech_config': {
            'voice_config': {
              'prebuilt_voice_config': {'voice_name': 'Aoede'},
            },
          },
        },
        // VAD config — tells Gemini to auto-detect end of speech
        'realtime_input_config': {
          'automatic_activity_detection': {
            'disabled': false, // enable VAD
            'start_of_speech_sensitivity': 'START_SENSITIVITY_LOW',
            'end_of_speech_sensitivity': 'END_SENSITIVITY_LOW',
            'prefix_padding_ms': 300,
            'silence_duration_ms': 700, // reply after 700ms silence
          },
        },
        'input_audio_transcription': {},
        'output_audio_transcription': {},
        if (systemPrompt.isNotEmpty)
          'system_instruction': {
            'parts': [
              {'text': systemPrompt},
            ],
          },
      },
    };

    _log('Sending setup: ${jsonEncode(setup)}');
    _sendRaw(jsonEncode(setup));
  }

  // ── Send audio chunk ───────────────────────────────
  // Only call AFTER setupDone = true
  void sendAudioChunk(Uint8List pcmBytes) {
    if (!isReady) {
      _log('sendAudioChunk skipped — not ready (setupDone=$_setupDone)');
      return;
    }
    final b64 = base64Encode(pcmBytes);
    _sendRaw(
      jsonEncode({
        'realtime_input': {
          'audio': {'data': b64, 'mime_type': 'audio/pcm;rate=16000'},
        },
      }),
    );
  }

  // ── Send text ─────────────────────────────────────
  void sendText(String text) {
    if (!isReady) {
      _log('sendText skipped — not ready');
      return;
    }
    _log('Sending text: $text');
    _sendRaw(
      jsonEncode({
        'realtime_input': {'text': text},
      }),
    );
  }

  // ── Disconnect ─────────────────────────────────────
  Future<void> disconnect() async {
    _isConnected = false;
    _setupDone = false;
    await _wsSub?.cancel();
    await _channel?.close();
    _channel = null;
    await _controller?.close();
    _controller = null;
    _log('Disconnected');
  }

  // ── Internals ─────────────────────────────────────

  void _sendRaw(String json) {
    try {
      _channel?.add(json);
    } catch (e) {
      _log('Send error: $e');
      _controller?.add(LiveApiError('Send error: $e'));
    }
  }

  void _onMessage(dynamic raw) {
    // Convert to string
    final String text;
    if (raw is String) {
      text = raw;
    } else if (raw is Uint8List) {
      text = utf8.decode(raw, allowMalformed: true);
    } else if (raw is List<int>) {
      text = utf8.decode(raw, allowMalformed: true);
    } else {
      _log('Unknown frame type: ${raw.runtimeType}');
      return;
    }

    if (text.trim().isEmpty) return;

    _log('Received: $text');

    Map<String, dynamic> msg;
    try {
      msg = jsonDecode(text) as Map<String, dynamic>;
    } catch (e) {
      _log('JSON parse error: $e');
      _controller?.add(LiveApiError('JSON parse error: $e'));
      return;
    }

    // ── Setup complete ────────────────────────────────
    if (msg.containsKey('setupComplete')) {
      _log('Setup complete — ready to receive audio');
      _setupDone = true;
      _controller?.add(LiveApiSetupDone());
      return;
    }

    // ── Server content ────────────────────────────────
    if (msg.containsKey('serverContent')) {
      final sc = msg['serverContent'] as Map<String, dynamic>;

      // Audio
      final modelTurn = sc['modelTurn'] as Map<String, dynamic>?;
      final parts = modelTurn?['parts'] as List<dynamic>?;
      if (parts != null) {
        for (final part in parts) {
          final inline =
              (part as Map<String, dynamic>)['inlineData']
                  as Map<String, dynamic>?;
          if (inline != null) {
            final data = inline['data'] as String?;
            if (data != null && data.isNotEmpty) {
              final pcm = base64Decode(data);
              _log('Audio chunk: ${pcm.length} bytes');
              _controller?.add(LiveApiAudioChunk(pcm));
            }
          }
          // Text part (if model replies with text)
          final partText = part['text'] as String?;
          if (partText != null && partText.isNotEmpty) {
            _log('Text part: $partText');
            _controller?.add(LiveApiTranscript(text: partText, isUser: false));
          }
        }
      }

      // Input transcription
      final inputTx = sc['inputTranscription'] as Map<String, dynamic>?;
      final inputText = inputTx?['text'] as String?;
      if (inputText != null && inputText.isNotEmpty) {
        _log('User said: $inputText');
        _controller?.add(LiveApiTranscript(text: inputText, isUser: true));
      }

      // Output transcription
      final outputTx = sc['outputTranscription'] as Map<String, dynamic>?;
      final outputText = outputTx?['text'] as String?;
      if (outputText != null && outputText.isNotEmpty) {
        _log('Gemini said: $outputText');
        _controller?.add(LiveApiTranscript(text: outputText, isUser: false));
      }

      // Turn complete
      if (sc['turnComplete'] == true) {
        _log('Turn complete');
        _controller?.add(LiveApiTurnComplete());
      }

      // Generation complete (fires before turnComplete sometimes)
      if (sc['generationComplete'] == true) {
        _log('Generation complete');
      }
    }

    // ── Server error ──────────────────────────────────
    if (msg.containsKey('error')) {
      final err = msg['error'] as Map<String, dynamic>;
      final errMsg = '${err['status'] ?? 'ERROR'}: ${err['message'] ?? text}';
      _log('Server error: $errMsg');
      _controller?.add(LiveApiError(errMsg));
    }
  }
}
