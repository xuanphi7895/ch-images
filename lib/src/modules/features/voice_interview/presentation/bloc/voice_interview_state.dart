// class VoiceInterviewState {
//   final String currentQuestion;

//   final String aiResponse;

//   const VoiceInterviewState({
//     required this.currentQuestion,
//     required this.aiResponse,
//   });

//   factory VoiceInterviewState.initial() {
//     return const VoiceInterviewState(
//       currentQuestion: 'Explain Dependency Injection.',
//       aiResponse: '',
//     );
//   }

//   VoiceInterviewState copyWith({String? currentQuestion, String? aiResponse}) {
//     return VoiceInterviewState(
//       currentQuestion: currentQuestion ?? this.currentQuestion,
//       aiResponse: aiResponse ?? this.aiResponse,
//     );
//   }
// }

class VoiceInterviewState {
  final bool connected;
  final bool listening;
  final String transcript;
  final String aiMessage;

  const VoiceInterviewState({
    required this.connected,
    required this.listening,
    required this.transcript,
    required this.aiMessage,
  });

  factory VoiceInterviewState.initial() {
    return const VoiceInterviewState(
      connected: false,
      listening: false,
      transcript: '',
      aiMessage: '',
    );
  }
}
