import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/voice_interview/presentation/bloc/gemini_live_service.dart';
import 'package:images/src/modules/features/voice_interview/presentation/bloc/voiceI_iterview_event.dart';
import 'package:images/src/modules/features/voice_interview/presentation/bloc/voice_interview_state.dart';

class VoiceInterviewBloc
    extends Bloc<VoiceInterviewEvent, VoiceInterviewState> {
  final GeminiLiveService service;

  VoiceInterviewBloc(this.service) : super(VoiceInterviewState.initial()) {
    // on<SendAnswerEvent>(
    //   _onSendAnswer,
    // );
  }

  // Future<void> _onSendAnswer(
  //   SendAnswerEvent event,
  //   Emitter<VoiceInterviewState> emit,
  // ) async {

  //   final result =
  //       await service.evaluateAnswer(
  //     event.answer,
  //   );

  //   emit(
  //     state.copyWith(
  //       aiResponse: result,
  //     ),
  //   );
  // }
}
