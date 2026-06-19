// gemini_live_bloc.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'gemini_live_service.dart';
import 'audio_helpers.dart';

// ═══════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════

class LiveMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isStreaming;

  const LiveMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isStreaming = false,
  });

  LiveMessage copyWith({String? text, bool? isStreaming}) => LiveMessage(
    text: text ?? this.text,
    isUser: isUser,
    timestamp: timestamp,
    isStreaming: isStreaming ?? this.isStreaming,
  );

  @override
  List<Object?> get props => [text, isUser, timestamp, isStreaming];
}

// ═══════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════

abstract class LiveEvent extends Equatable {
  const LiveEvent();
  @override
  List<Object?> get props => [];
}

class LiveStarted extends LiveEvent {
  const LiveStarted();
}

class LiveStopped extends LiveEvent {
  const LiveStopped();
}

class LiveMicToggled extends LiveEvent {
  const LiveMicToggled();
}

class LiveTextSent extends LiveEvent {
  final String text;
  const LiveTextSent(this.text);
  @override
  List<Object?> get props => [text];
}

// Internal — wraps service stream events into BLoC events
class _ServiceEvent extends LiveEvent {
  final LiveApiEvent event;
  const _ServiceEvent(this.event);
  @override
  List<Object?> get props => [event];
}

// ═══════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════

enum LiveStatus {
  disconnected,
  connecting, // WebSocket open, waiting for setupComplete
  idle, // setupComplete received, ready to talk
  listening, // mic on, sending audio
  aiSpeaking, // playing Gemini audio
}

abstract class LiveState extends Equatable {
  const LiveState();
  @override
  List<Object?> get props => [];
}

class LiveInitial extends LiveState {
  const LiveInitial();
}

class LiveReady extends LiveState {
  final LiveStatus status;
  final List<LiveMessage> messages;
  final String? errorMessage;

  const LiveReady({
    required this.status,
    required this.messages,
    this.errorMessage,
  });

  LiveReady copyWith({
    LiveStatus? status,
    List<LiveMessage>? messages,
    String? errorMessage,
  }) => LiveReady(
    status: status ?? this.status,
    messages: messages ?? this.messages,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, messages, errorMessage];
}

// ═══════════════════════════════════════════
// BLOC
// ═══════════════════════════════════════════

class GeminiLiveBloc extends Bloc<LiveEvent, LiveState> {
  // ── Replace with your Gemini API key ──────
  static const _apiKey =
      'AQ.Ab8RN6KDrR_lsIov0RHJOP7TuFBXqznVyVjTwVx2w2LNLjNAFg';

  static const _systemPrompt =
      'You are a friendly English conversation tutor. '
      'Keep replies short — 1 to 3 sentences. '
      'If the user makes a grammar mistake, gently correct it. '
      'Always ask a follow-up question.';

  late final GeminiLiveService _service;
  final _mic = MicRecorder();
  final _player = PcmPlayer();

  StreamSubscription<LiveApiEvent>? _serviceSub;
  StreamSubscription<Uint8List>? _micSub;
  bool _micActive = false;

  GeminiLiveBloc() : super(const LiveInitial()) {
    _service = GeminiLiveService(
      apiKey: _apiKey,
      model: 'gemini-2.5-flash-native-audio-preview-12-2025',
      systemPrompt: _systemPrompt,
    );

    on<LiveStarted>(_onStarted);
    on<LiveStopped>(_onStopped);
    on<LiveMicToggled>(_onMicToggled);
    on<LiveTextSent>(_onTextSent);
    on<_ServiceEvent>(_onServiceEvent);
  }

  // ── Connect ────────────────────────────────────────

  Future<void> _onStarted(LiveStarted event, Emitter<LiveState> emit) async {
    // Disconnect old session if any
    if (_service.isConnected) {
      await _service.disconnect();
    }

    emit(const LiveReady(status: LiveStatus.connecting, messages: []));

    try {
      await _player.init();

      // Forward service events into BLoC
      await _serviceSub?.cancel();
      _serviceSub = _service.events.listen((e) => add(_ServiceEvent(e)));

      await _service.connect();

      // Wait for setupComplete handled in _onServiceEvent
      // Status stays 'connecting' until LiveApiSetupDone fires
    } catch (e) {
      emit(
        LiveReady(
          status: LiveStatus.disconnected,
          messages: [],
          errorMessage: 'Failed to connect: $e',
        ),
      );
    }
  }

  // ── Disconnect ─────────────────────────────────────

  Future<void> _onStopped(LiveStopped event, Emitter<LiveState> emit) async {
    await _stopMic();
    await _serviceSub?.cancel();
    await _service.disconnect();
    await _player.stop();

    if (state is LiveReady) {
      emit((state as LiveReady).copyWith(status: LiveStatus.disconnected));
    }
  }

  // ── Mic toggle ─────────────────────────────────────

  Future<void> _onMicToggled(
    LiveMicToggled event,
    Emitter<LiveState> emit,
  ) async {
    if (state is! LiveReady) return;
    final s = state as LiveReady;

    // Only allow toggling when idle or already listening
    if (s.status == LiveStatus.aiSpeaking ||
        s.status == LiveStatus.connecting ||
        s.status == LiveStatus.disconnected)
      return;

    if (_micActive) {
      await _stopMic();
      emit(s.copyWith(status: LiveStatus.idle));
    } else {
      await _startMic();
      emit(s.copyWith(status: LiveStatus.listening));
    }
  }

  // ── Send text ──────────────────────────────────────

  void _onTextSent(LiveTextSent event, Emitter<LiveState> emit) {
    if (state is! LiveReady) return;
    final s = state as LiveReady;
    if (!_service.isReady) return;

    _service.sendText(event.text);

    emit(
      s.copyWith(
        messages: [
          ...s.messages,
          LiveMessage(
            text: event.text,
            isUser: true,
            timestamp: DateTime.now(),
          ),
        ],
      ),
    );
  }

  // ── Handle service events ──────────────────────────

  Future<void> _onServiceEvent(
    _ServiceEvent wrapper,
    Emitter<LiveState> emit,
  ) async {
    final e = wrapper.event;
    if (state is! LiveReady) return;
    final s = state as LiveReady;

    // ── Setup done → show greeting, ready to talk ──
    if (e is LiveApiSetupDone) {
      emit(
        s.copyWith(
          status: LiveStatus.idle,
          messages: [
            LiveMessage(
              text: 'Connected! Tap the mic and start speaking in English.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
        ),
      );
    }
    // ── Connected (WebSocket open) ──
    else if (e is LiveApiConnected) {
      // Stay in 'connecting' — wait for setupComplete
    }
    // ── Disconnected ──
    else if (e is LiveApiDisconnected) {
      await _stopMic();
      emit(s.copyWith(status: LiveStatus.disconnected));
    }
    // ── Error ──
    else if (e is LiveApiError) {
      await _stopMic();
      emit(
        s.copyWith(
          status: s.status == LiveStatus.connecting
              ? LiveStatus.disconnected
              : s.status,
          errorMessage: e.message,
        ),
      );
    }
    // ── Audio chunk — buffer it ──
    else if (e is LiveApiAudioChunk) {
      _player.feedChunk(e.pcmBytes);
      if (s.status != LiveStatus.aiSpeaking) {
        // Stop mic while AI speaks (avoids echo)
        await _stopMic();
        emit(s.copyWith(status: LiveStatus.aiSpeaking));
      }
    }
    // ── Transcript ──
    else if (e is LiveApiTranscript) {
      final messages = List<LiveMessage>.from(s.messages);

      if (e.isUser) {
        // Update or add user bubble
        if (messages.isNotEmpty &&
            messages.last.isUser &&
            messages.last.isStreaming) {
          messages[messages.length - 1] = messages.last.copyWith(
            text: e.text,
            isStreaming: false,
          );
        } else {
          messages.add(
            LiveMessage(
              text: e.text,
              isUser: true,
              timestamp: DateTime.now(),
              isStreaming: false,
            ),
          );
        }
      } else {
        // Append to AI bubble
        if (messages.isNotEmpty &&
            !messages.last.isUser &&
            messages.last.isStreaming) {
          messages[messages.length - 1] = messages.last.copyWith(
            text: messages.last.text + e.text,
            isStreaming: true,
          );
        } else {
          messages.add(
            LiveMessage(
              text: e.text,
              isUser: false,
              timestamp: DateTime.now(),
              isStreaming: true,
            ),
          );
        }
      }

      emit(s.copyWith(messages: messages));
    }
    // ── Turn complete → play all buffered audio ──
    else if (e is LiveApiTurnComplete) {
      // Finalize streaming bubble
      final messages = List<LiveMessage>.from(s.messages);
      if (messages.isNotEmpty && messages.last.isStreaming) {
        messages[messages.length - 1] = messages.last.copyWith(
          isStreaming: false,
        );
      }

      emit(s.copyWith(status: LiveStatus.aiSpeaking, messages: messages));

      // Play the full buffered response as one clean audio clip
      await _player.playBuffered();

      // Back to idle
      if (state is LiveReady) {
        emit((state as LiveReady).copyWith(status: LiveStatus.idle));
      }
    }
  }

  // ── Mic helpers ────────────────────────────────────

  Future<void> _startMic() async {
    if (_micActive) return;
    _micActive = true;
    await _mic.start();
    _micSub = _mic.chunks.listen((chunk) {
      if (_micActive && _service.isReady) {
        _service.sendAudioChunk(chunk);
      }
    });
  }

  Future<void> _stopMic() async {
    if (!_micActive) return;
    _micActive = false;
    await _micSub?.cancel();
    _micSub = null;
    await _mic.stop();
  }

  @override
  Future<void> close() async {
    await _stopMic();
    await _serviceSub?.cancel();
    await _service.disconnect();
    await _player.dispose();
    _mic.dispose();
    super.close();
  }
}
