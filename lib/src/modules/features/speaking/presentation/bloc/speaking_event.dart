// ═══════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════
import 'package:equatable/equatable.dart';
import 'package:images/src/modules/features/speaking/data/speaking_models.dart';

abstract class SpeakingEvent extends Equatable {
  const SpeakingEvent();
  @override
  List<Object?> get props => [];
}

class SpeakingScreenLoaded extends SpeakingEvent {
  const SpeakingScreenLoaded();
}

class SpeakingScenarioSelected extends SpeakingEvent {
  final SpeakingScenarioData scenario;
  const SpeakingScenarioSelected(this.scenario);
  @override
  List<Object?> get props => [scenario];
}

class SpeakingMicPressed extends SpeakingEvent {
  const SpeakingMicPressed();
}

class SpeakingMicReleased extends SpeakingEvent {
  const SpeakingMicReleased();
}

class SpeakingWordDetected extends SpeakingEvent {
  final String text;
  const SpeakingWordDetected(this.text);
  @override
  List<Object?> get props => [text];
}

class SpeakingSubmitted extends SpeakingEvent {
  final String text;
  const SpeakingSubmitted(this.text);
  @override
  List<Object?> get props => [text];
}

class SpeakingAiReplied extends SpeakingEvent {
  final String aiText;
  final SpeakingFeedback feedback;
  const SpeakingAiReplied(this.aiText, this.feedback);
  @override
  List<Object?> get props => [aiText, feedback];
}

class SpeakingTtsFinished extends SpeakingEvent {
  const SpeakingTtsFinished();
}

class SpeakingFeedbackToggled extends SpeakingEvent {
  final String turnId;
  const SpeakingFeedbackToggled(this.turnId);
  @override
  List<Object?> get props => [turnId];
}

class SpeakingHintRequested extends SpeakingEvent {
  const SpeakingHintRequested();
}

class SpeakingSessionEnded extends SpeakingEvent {
  const SpeakingSessionEnded();
}

class SpeakingRestarted extends SpeakingEvent {
  const SpeakingRestarted();
}

class SpeakingErrorOccurred extends SpeakingEvent {
  final String message;
  const SpeakingErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}
