import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:record/record.dart';

class GeminiLiveScreen extends StatefulWidget {
  const GeminiLiveScreen({super.key});

  @override
  State<GeminiLiveScreen> createState() => _GeminiLiveScreenState();
}

class _GeminiLiveScreenState extends State<GeminiLiveScreen> {
  // Replace with your protected API Key
  final String _apiKey =
      "AQ.Ab8RN6KDrR_lsIov0RHJOP7TuFBXqznVyVjTwVx2w2LNLjNAFg";

  WebSocketChannel? _channel;
  StreamSubscription? _socketSubscription;
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _micStreamSubscription;

  bool _isLive = false;
  String _statusText = "Disconnected";

  @override
  void dispose() {
    _disconnectLiveSession();
    _audioRecorder.dispose();
    super.dispose();
  }

  /// Establishes bidirectional connection and kicks off mic audio capture
  Future<void> _connectLiveSession() async {
    // 1. Build the Stateful WebSocket URL for the Live API
    final wsUri = Uri.parse(
      'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=$_apiKey',
    );

    try {
      _channel = WebSocketChannel.connect(wsUri);
      setState(() {
        _isLive = true;
        _statusText = "Connecting...";
      });

      // 2. Send the required first-frame initial setup config handshake
      final setupHandshake = {
        "setup": {
          "model": "models/gemini-2.5-flash-native-audio-preview-12-2025",
          "generationConfig": {
            "responseModalities": [
              "AUDIO",
            ], // Instruct Gemini to talk back, not write back
            "speechConfig": {
              "voiceConfig": {
                "prebuiltVoiceConfig": {
                  "voiceName": "Aoede",
                }, // Voice choices: Aoede, Charon, Fenrir, Kore, Puck
              },
            },
          },
        },
      };
      _channel!.sink.add(jsonEncode(setupHandshake));

      // 3. Listen to incoming audio data chunks emitted from Gemini
      _socketSubscription = _channel!.stream.listen(
        (message) => _handleServerResponse(message),
        onError: (err) => _handleFailure("Socket error: $err"),
        onDone: () => _handleFailure("Session closed by server"),
      );

      // 4. Begin capturing and streaming physical mic input bytes
      await _startMicrophoneStreaming();
    } catch (e) {
      _handleFailure("Connection failed: $e");
    }
  }

  /// Captures native input and converts chunks into PCM 16-bit, 16kHz audio strings
  Future<void> _startMicrophoneStreaming() async {
    if (await _audioRecorder.hasPermission()) {
      // Configuration tailored to Gemini Live requirements
      const recordConfig = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      );

      final stream = await _audioRecorder.startStream(recordConfig);

      _micStreamSubscription = stream.listen((Uint8List audioChunk) {
        if (_channel != null && _isLive) {
          // Wrap raw chunk bytes into base64 realtime input data payloads
          final base64Chunk = base64Encode(audioChunk);
          final inputFrame = {
            "realtimeInput": {
              "mediaChunks": [
                {"mimeType": "audio/pcm", "data": base64Chunk},
              ],
            },
          };
          _channel!.sink.add(jsonEncode(inputFrame));
        }
      });

      setState(() => _statusText = "Live (Listening and Speaking)");
    } else {
      _handleFailure("Microphone permission denied.");
    }
  }

  /// Parses incoming data frames and extracts audio parts for your client player
  void _handleServerResponse(dynamic message) {
    try {
      String jsonString;

      if (message is String) {
        jsonString = message;
      } else if (message is Uint8List) {
        jsonString = utf8.decode(message);
      } else {
        debugPrint('Unsupported message type: ${message.runtimeType}');
        return;
      }

      final Map<String, dynamic> response = jsonDecode(jsonString);

      if (response['serverContent'] != null &&
          response['serverContent']['modelTurn'] != null) {
        final parts =
            response['serverContent']['modelTurn']['parts'] as List<dynamic>;

        for (final part in parts) {
          final inlineData = part['inlineData'];

          if (inlineData != null &&
              inlineData['mimeType'].toString().contains('audio')) {
            final base64Audio = inlineData['data'] as String;

            _playAudioChunk(base64Audio);
          }
        }
      }

      if (response['serverContent']?['interrupted'] == true) {
        _stopLocalAudioPlayback();
      }
    } catch (e, st) {
      debugPrint('Error parsing server chunk: $e');
      debugPrint(st.toString());
    }
  }

  void _playAudioChunk(String base64Audio) {
    // Decode base64Audio into raw Uint8List PCM chunks.
    // Pass this data buffer into an audio output pipeline supporting raw byte playback.
    // e.g., using a custom package loop or raw audio track stream writer.
    Uint8List rawBytes = base64Decode(base64Audio);
    debugPrint("Received audio chunk: ${rawBytes.length} bytes.");
  }

  void _stopLocalAudioPlayback() {
    debugPrint(
      "Gemini detected user interruption. Stopping local output track instantly.",
    );
    // Invoke your active player instance .stop() method here
  }

  void _disconnectLiveSession() {
    _micStreamSubscription?.cancel();
    _audioRecorder.stop();
    _socketSubscription?.cancel();
    _channel?.sink.close();

    setState(() {
      _isLive = false;
      _statusText = "Disconnected";
    });
  }

  void _handleFailure(String error) {
    debugPrint(error);
    _disconnectLiveSession();
    setState(() => _statusText = error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gemini Live Chat SDK")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isLive ? Icons.record_voice_over : Icons.voice_over_off,
              size: 80,
              color: _isLive ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              "Status: $_statusText",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLive ? Colors.redAccent : Colors.blueAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              onPressed: _isLive ? _disconnectLiveSession : _connectLiveSession,
              child: Text(
                _isLive ? "End Session" : "Start Gemini Live",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
