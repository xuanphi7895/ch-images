// part of 'gemini_live_bloc.dart';

// ─── Connection status ────────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';

import '../../../../utils/enum.dart';

// enum ConnectionStatus { disconnected, connecting, connected, error }

// ─── A single chat message ────────────────────────────────────────────────────
class ChatMessage extends Equatable {
  final String id;
  final String text;
  final bool isUser;
  final bool isStreaming; // model response still arriving
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.isStreaming = false,
    required this.timestamp,
  });

  ChatMessage copyWith({String? text, bool? isStreaming}) => ChatMessage(
    id: id,
    text: text ?? this.text,
    isUser: isUser,
    isStreaming: isStreaming ?? this.isStreaming,
    timestamp: timestamp,
  );

  @override
  List<Object?> get props => [id, text, isUser, isStreaming, timestamp];
}

// ─── BLoC State ───────────────────────────────────────────────────────────────
class GeminiLiveState extends Equatable {
  final ConnectionStatus connectionStatus;
  final List<ChatMessage> messages;
  final bool isRecording;
  final bool isModelSpeaking;
  final String? errorMessage;

  const GeminiLiveState({
    this.connectionStatus = ConnectionStatus.disconnected,
    this.messages = const [],
    this.isRecording = false,
    this.isModelSpeaking = false,
    this.errorMessage,
  });

  bool get isConnected => connectionStatus == ConnectionStatus.connected;
  bool get canSend => isConnected && !isRecording;

  GeminiLiveState copyWith({
    ConnectionStatus? connectionStatus,
    List<ChatMessage>? messages,
    bool? isRecording,
    bool? isModelSpeaking,
    String? errorMessage,
    bool clearError = false,
  }) => GeminiLiveState(
    connectionStatus: connectionStatus ?? this.connectionStatus,
    messages: messages ?? this.messages,
    isRecording: isRecording ?? this.isRecording,
    isModelSpeaking: isModelSpeaking ?? this.isModelSpeaking,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [
    connectionStatus,
    messages,
    isRecording,
    isModelSpeaking,
    errorMessage,
  ];
}
