import 'dart:typed_data';

abstract class VoiceInterviewEvent {}

class ConnectSession extends VoiceInterviewEvent {}

class StartRecording extends VoiceInterviewEvent {}

class StopRecording extends VoiceInterviewEvent {}

class AudioChunkCaptured extends VoiceInterviewEvent {
  final Uint8List bytes;

  AudioChunkCaptured(this.bytes);
}
