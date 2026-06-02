import 'package:equatable/equatable.dart';

class TtsState extends Equatable {
  final String text;
  final int start;
  final int end;
  final bool isSpeaking;

  const TtsState({
    required this.text,
    required this.start,
    required this.end,
    required this.isSpeaking,
  });

  factory TtsState.initial() {
    return const TtsState(text: '', start: 0, end: 0, isSpeaking: false);
  }

  TtsState copyWith({String? text, int? start, int? end, bool? isSpeaking}) {
    return TtsState(
      text: text ?? this.text,
      start: start ?? this.start,
      end: end ?? this.end,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }

  @override
  List<Object> get props => [text, start, end, isSpeaking];
}
