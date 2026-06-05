// ─── Events ───────────────────────────────────────

import 'package:equatable/equatable.dart';

abstract class PronunEvent extends Equatable {
  const PronunEvent();
  @override
  List<Object?> get props => [];
}

class PronunStarted extends PronunEvent {
  const PronunStarted();
}

class PronunPlaybackRequested extends PronunEvent {
  const PronunPlaybackRequested();
}

class PronunRecordingStarted extends PronunEvent {
  const PronunRecordingStarted();
}

class PronunRecordingSubmitted extends PronunEvent {
  // In production: pass the recorded audio bytes/path here
  final String? recordingPath;
  const PronunRecordingSubmitted({this.recordingPath});
  @override
  List<Object?> get props => [recordingPath];
}

class PronunNextWord extends PronunEvent {
  const PronunNextWord();
}
