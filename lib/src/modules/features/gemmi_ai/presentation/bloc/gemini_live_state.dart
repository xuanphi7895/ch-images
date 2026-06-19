import 'package:equatable/equatable.dart';

import '../../../../../utils/enum.dart';
import '../../domain/chat_model.dart';

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
