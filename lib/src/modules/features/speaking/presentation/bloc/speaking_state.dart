// ═══════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════
import 'package:equatable/equatable.dart';
import 'package:images/src/modules/features/speaking/data/speaking_models.dart';

enum SpeakingStatus {
  idle, // waiting for user to press mic
  recording, // mic on, STT running
  processing, // sent to AI, waiting reply
  aiSpeaking, // TTS playing AI response
}

abstract class SpeakingState extends Equatable {
  const SpeakingState();
  @override
  List<Object?> get props => [];
}

class SpeakingInitial extends SpeakingState {
  const SpeakingInitial();
}

// Scenario selection screen
class SpeakingScenarioPicker extends SpeakingState {
  final List<SpeakingScenarioData> scenarios;
  const SpeakingScenarioPicker({required this.scenarios});
  @override
  List<Object?> get props => [scenarios];
}

// Active conversation
class SpeakingConversation extends SpeakingState {
  final SpeakingScenarioData scenario;
  final SpeakingStatus status;
  final List<SpeakingTurn> turns;
  final String liveTranscript;
  final String? expandedFeedbackTurnId;
  final String? hint;
  final String? errorMessage;

  const SpeakingConversation({
    required this.scenario,
    required this.status,
    required this.turns,
    this.liveTranscript = '',
    this.expandedFeedbackTurnId,
    this.hint,
    this.errorMessage,
  });

  int get userTurnCount => turns.where((t) => t.role == TurnRole.user).length;

  SpeakingConversation copyWith({
    SpeakingStatus? status,
    List<SpeakingTurn>? turns,
    String? liveTranscript,
    String? expandedFeedbackTurnId,
    String? hint,
    String? errorMessage,
    bool clearError = false,
    bool clearHint = false,
    bool clearExpanded = false,
  }) {
    return SpeakingConversation(
      scenario: scenario,
      status: status ?? this.status,
      turns: turns ?? this.turns,
      liveTranscript: liveTranscript ?? this.liveTranscript,
      expandedFeedbackTurnId: clearExpanded
          ? null
          : expandedFeedbackTurnId ?? this.expandedFeedbackTurnId,
      hint: clearHint ? null : hint ?? this.hint,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    scenario,
    status,
    turns,
    liveTranscript,
    expandedFeedbackTurnId,
    hint,
    errorMessage,
  ];
}

// Results screen
class SpeakingDone extends SpeakingState {
  final SpeakingScenarioData scenario;
  final SpeakingResult result;
  const SpeakingDone({required this.scenario, required this.result});
  @override
  List<Object?> get props => [scenario, result];
}
