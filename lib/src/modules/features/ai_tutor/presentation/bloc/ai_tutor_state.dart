import 'package:equatable/equatable.dart';
import 'package:images/src/modules/features/ai_tutor/data/ai_tutor_model.dart';

class GrammarCorrection extends Equatable {
  final String original;
  final String corrected;
  final String explanation;

  const GrammarCorrection({
    required this.original,
    required this.corrected,
    required this.explanation,
  });

  @override
  List<Object?> get props => [original, corrected, explanation];
}

class ChatMessage extends Equatable {
  final String id;
  final String sender; // 'user' or 'tutor'
  final String text;
  final String translation;
  final DateTime timestamp;
  final GrammarCorrection? correction;
  final bool showTranslation;
  final bool isSpeaking;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.translation,
    required this.timestamp,
    this.correction,
    this.showTranslation = false,
    this.isSpeaking = false,
  });

  ChatMessage copyWith({
    String? id,
    String? sender,
    String? text,
    String? translation,
    DateTime? timestamp,
    GrammarCorrection? correction,
    bool? showTranslation,
    bool? isSpeaking,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      timestamp: timestamp ?? this.timestamp,
      correction: correction ?? this.correction,
      showTranslation: showTranslation ?? this.showTranslation,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sender,
        text,
        translation,
        timestamp,
        correction,
        showTranslation,
        isSpeaking,
      ];
}

abstract class AiTutorState extends Equatable {
  const AiTutorState();

  @override
  List<Object?> get props => [];
}

class AiTutorInitial extends AiTutorState {
  const AiTutorInitial();
}

class AiTutorReady extends AiTutorState {
  final AiTutor tutor;
  final List<ChatMessage> messages;
  final bool isTutorTyping;
  final bool isRecordingVoice;
  final String? playingTTSMessageId;

  const AiTutorReady({
    required this.tutor,
    required this.messages,
    this.isTutorTyping = false,
    this.isRecordingVoice = false,
    this.playingTTSMessageId,
  });

  AiTutorReady copyWith({
    AiTutor? tutor,
    List<ChatMessage>? messages,
    bool? isTutorTyping,
    bool? isRecordingVoice,
    String? playingTTSMessageId,
  }) {
    return AiTutorReady(
      tutor: tutor ?? this.tutor,
      messages: messages ?? this.messages,
      isTutorTyping: isTutorTyping ?? this.isTutorTyping,
      isRecordingVoice: isRecordingVoice ?? this.isRecordingVoice,
      playingTTSMessageId: playingTTSMessageId, // can be null
    );
  }

  @override
  List<Object?> get props => [
        tutor,
        messages,
        isTutorTyping,
        isRecordingVoice,
        playingTTSMessageId,
      ];
}
