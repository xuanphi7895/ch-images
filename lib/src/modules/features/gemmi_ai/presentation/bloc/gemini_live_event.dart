// part of 'gemini_live_bloc.dart';

import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class GeminiLiveBlocEvent extends Equatable {
  const GeminiLiveBlocEvent();
  @override
  List<Object?> get props => [];
}

/// User taps "Connect"
class ConnectRequested extends GeminiLiveBlocEvent {
  final String apiKey;
  final String? systemInstruction;
  const ConnectRequested({required this.apiKey, this.systemInstruction});
  @override
  List<Object?> get props => [apiKey, systemInstruction];
}

/// User taps "Disconnect"
class DisconnectRequested extends GeminiLiveBlocEvent {}

/// User sends a text message
class SendTextMessage extends GeminiLiveBlocEvent {
  final String text;
  const SendTextMessage(this.text);
  @override
  List<Object?> get props => [text];
}

/// Microphone recording started
class StartVoiceInput extends GeminiLiveBlocEvent {}

/// Microphone recording stopped
class StopVoiceInput extends GeminiLiveBlocEvent {}

/// Raw audio chunk captured from mic (streamed to Gemini)
class AudioChunkCaptured extends GeminiLiveBlocEvent {
  final Uint8List bytes;
  const AudioChunkCaptured(this.bytes);
  @override
  List<Object?> get props => [bytes];
}

/// WebSocket is confirmed open
class _WsConnected extends GeminiLiveBlocEvent {}

/// WebSocket closed
class _WsDisconnected extends GeminiLiveBlocEvent {
  final String? reason;
  const _WsDisconnected({this.reason});
}

/// Error from WebSocket
class _WsError extends GeminiLiveBlocEvent {
  final String message;
  const _WsError(this.message);
}

/// Streaming text from the model
class _ModelTextReceived extends GeminiLiveBlocEvent {
  final String text;
  final bool isFinal;
  const _ModelTextReceived(this.text, {this.isFinal = false});
}

/// Audio bytes from the model
class _ModelAudioReceived extends GeminiLiveBlocEvent {
  final Uint8List bytes;
  const _ModelAudioReceived(this.bytes);
}

/// Model signaled turn complete
class _ModelTurnComplete extends GeminiLiveBlocEvent {}

/// User taps "Interrupt"
class InterruptRequested extends GeminiLiveBlocEvent {}
