abstract class TtsEvent {}

class SpeakTextEvent extends TtsEvent {
  final String text;

  SpeakTextEvent(this.text);
}

class ProgressChangedEvent extends TtsEvent {
  final int start;
  final int end;

  ProgressChangedEvent({required this.start, required this.end});
}

class StopTtsEvent extends TtsEvent {}
