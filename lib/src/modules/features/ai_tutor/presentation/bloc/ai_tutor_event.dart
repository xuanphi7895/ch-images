import 'package:equatable/equatable.dart';
import 'package:images/src/modules/features/ai_tutor/data/ai_tutor_model.dart';

abstract class AiTutorEvent extends Equatable {
  const AiTutorEvent();

  @override
  List<Object?> get props => [];
}

class AiTutorSessionStarted extends AiTutorEvent {
  final AiTutor tutor;

  const AiTutorSessionStarted(this.tutor);

  @override
  List<Object?> get props => [tutor];
}

class AiTutorMessageSent extends AiTutorEvent {
  final String text;

  const AiTutorMessageSent(this.text);

  @override
  List<Object?> get props => [text];
}

class AiTutorVoiceSimulationStarted extends AiTutorEvent {
  const AiTutorVoiceSimulationStarted();
}

class AiTutorVoiceSimulationFinished extends AiTutorEvent {
  final String simulatedText;

  const AiTutorVoiceSimulationFinished(this.simulatedText);

  @override
  List<Object?> get props => [simulatedText];
}

class AiTutorMessageTTSRequested extends AiTutorEvent {
  final String messageId;
  final String text;

  const AiTutorMessageTTSRequested({
    required this.messageId,
    required this.text,
  });

  @override
  List<Object?> get props => [messageId, text];
}

class AiTutorTTSStopped extends AiTutorEvent {
  const AiTutorTTSStopped();
}

class AiTutorTranslationToggled extends AiTutorEvent {
  final String messageId;

  const AiTutorTranslationToggled(this.messageId);

  @override
  List<Object?> get props => [messageId];
}
