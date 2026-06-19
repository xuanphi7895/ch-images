// import 'dart:async';
// import 'dart:typed_data';

// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:images/src/modules/features/gemmi_ai/gemini_live_service.dart';
// import 'package:images/src/modules/features/gemmi_ai/presentation/bloc/gemini_live_event.dart';
// import 'package:images/src/modules/features/gemmi_ai/presentation/bloc/gemini_live_state.dart';
// import 'package:logger/logger.dart';
// import 'package:uuid/uuid.dart';

// import '../../../../../utils/enum.dart';
// // import '../services/gemini_live_service.dart';

// // part 'gemini_live_event.dart';
// // part 'gemini_live_state.dart';

// const _uuid = Uuid();

// class GeminiLiveBloc extends Bloc<GeminiLiveBlocEvent, GeminiLiveState> {
//   GeminiLiveService? _service;
//   StreamSubscription<GeminiLiveEvent>? _serviceSub;
//   final _log = Logger();

//   GeminiLiveBloc() : super(const GeminiLiveState()) {
//     on<ConnectRequested>(_onConnect);
//     on<DisconnectRequested>(_onDisconnect);
//     on<SendTextMessage>(_onSendText);
//     on<StartVoiceInput>(_onStartVoice);
//     on<StopVoiceInput>(_onStopVoice);
//     on<AudioChunkCaptured>(_onAudioChunk);
//     on<InterruptRequested>(_onInterrupt);

//     // Internal events from service
//     on<_WsConnected>(_onWsConnected);
//     on<_WsDisconnected>(_onWsDisconnected);
//     on<_WsError>(_onWsError);
//     on<_ModelTextReceived>(_onModelText);
//     on<_ModelAudioReceived>(_onModelAudio);
//     on<_ModelTurnComplete>(_onTurnComplete);
//   }

//   // ── Connect ────────────────────────────────────────────────────────────────
//   Future<void> _onConnect(
//     ConnectRequested event,
//     Emitter<GeminiLiveState> emit,
//   ) async {
//     if (state.connectionStatus == ConnectionStatus.connected) return;

//     emit(state.copyWith(
//       connectionStatus: ConnectionStatus.connecting,
//       clearError: true,
//     ));

//     // Create & wire service
//     _service = GeminiLiveService(
//       apiKey: event.apiKey,
//       systemInstruction:
//           event.systemInstruction ?? 'You are a helpful assistant.',
//     );

//     _serviceSub = _service!.events.listen((geminiEvent) {
//       switch (geminiEvent) {
//         case GeminiConnectedEvent():
//           add(const _WsConnected());
//         case GeminiDisconnectedEvent(:final reason):
//           add(_WsDisconnected(reason: reason));
//         case GeminiErrorEvent(:final message):
//           add(_WsError(message));
//         case GeminiTextResponseEvent(:final text, :final isFinal):
//           add(_ModelTextReceived(text, isFinal: isFinal));
//         case GeminiAudioResponseEvent(:final audioBytes):
//           add(_ModelAudioReceived(audioBytes));
//         case GeminiTurnCompleteEvent():
//           add(_ModelTurnComplete());
//       }
//     });

//     await _service!.connect();
//   }

//   // ── Disconnect ─────────────────────────────────────────────────────────────
//   Future<void> _onDisconnect(
//     DisconnectRequested event,
//     Emitter<GeminiLiveState> emit,
//   ) async {
//     await _cleanupService();
//     emit(state.copyWith(
//       connectionStatus: ConnectionStatus.disconnected,
//       isRecording: false,
//       isModelSpeaking: false,
//     ));
//   }

//   // ── Send text ──────────────────────────────────────────────────────────────
//   void _onSendText(
//     SendTextMessage event,
//     Emitter<GeminiLiveState> emit,
//   ) {
//     if (!state.isConnected || event.text.trim().isEmpty) return;

//     // Add user message to chat
//     final userMsg = ChatMessage(
//       id: _uuid.v4(),
//       text: event.text.trim(),
//       isUser: true,
//       timestamp: DateTime.now(),
//     );

//     // Placeholder for model response (streaming)
//     final botMsg = ChatMessage(
//       id: _uuid.v4(),
//       text: '',
//       isUser: false,
//       isStreaming: true,
//       timestamp: DateTime.now(),
//     );

//     emit(state.copyWith(
//       messages: [...state.messages, userMsg, botMsg],
//       isModelSpeaking: true,
//     ));

//     _service!.sendText(event.text.trim());
//   }

//   // ── Voice input ────────────────────────────────────────────────────────────
//   void _onStartVoice(StartVoiceInput event, Emitter<GeminiLiveState> emit) {
//     if (!state.isConnected) return;
//     // Actual mic handling is done by the UI layer via AudioChunkCaptured
//     emit(state.copyWith(isRecording: true));
//   }

//   void _onStopVoice(StopVoiceInput event, Emitter<GeminiLiveState> emit) {
//     emit(state.copyWith(isRecording: false));
//   }

//   void _onAudioChunk(
//     AudioChunkCaptured event,
//     Emitter<GeminiLiveState> emit,
//   ) {
//     _service?.sendAudioChunk(event.bytes);
//   }

//   // ── Interrupt ──────────────────────────────────────────────────────────────
//   void _onInterrupt(InterruptRequested event, Emitter<GeminiLiveState> emit) {
//     _service?.interrupt();
//     emit(state.copyWith(isModelSpeaking: false));
//     // Mark last streaming message as done
//     final updated = _finalizeStreamingMessage(state.messages);
//     emit(state.copyWith(messages: updated, isModelSpeaking: false));
//   }

//   // ── Internal WS events ─────────────────────────────────────────────────────
//   void _onWsConnected(_WsConnected event, Emitter<GeminiLiveState> emit) {
//     emit(state.copyWith(connectionStatus: ConnectionStatus.connected));
//     _log.i('BLoC: WS connected');
//   }

//   void _onWsDisconnected(
//     _WsDisconnected event,
//     Emitter<GeminiLiveState> emit,
//   ) {
//     emit(state.copyWith(
//       connectionStatus: ConnectionStatus.disconnected,
//       isRecording: false,
//       isModelSpeaking: false,
//     ));
//     _log.i('BLoC: WS disconnected — ${event.reason}');
//   }

//   void _onWsError(_WsError event, Emitter<GeminiLiveState> emit) {
//     emit(state.copyWith(
//       connectionStatus: ConnectionStatus.error,
//       errorMessage: event.message,
//       isRecording: false,
//       isModelSpeaking: false,
//     ));
//   }

//   void _onModelText(
//     _ModelTextReceived event,
//     Emitter<GeminiLiveState> emit,
//   ) {
//     final messages = List<ChatMessage>.from(state.messages);

//     // Find the last streaming bot message and append
//     final idx = messages.lastIndexWhere((m) => !m.isUser && m.isStreaming);
//     if (idx != -1) {
//       messages[idx] = messages[idx].copyWith(
//         text: messages[idx].text + event.text,
//         isStreaming: !event.isFinal,
//       );
//     } else {
//       // Create a new bot message if none exists
//       messages.add(ChatMessage(
//         id: _uuid.v4(),
//         text: event.text,
//         isUser: false,
//         isStreaming: !event.isFinal,
//         timestamp: DateTime.now(),
//       ));
//     }

//     emit(state.copyWith(messages: messages));
//   }

//   void _onModelAudio(
//     _ModelAudioReceived event,
//     Emitter<GeminiLiveState> emit,
//   ) {
//     // Audio playback is handled outside BLoC (e.g., AudioPlayerService)
//     // BLoC only reflects that model is speaking
//     emit(state.copyWith(isModelSpeaking: true));
//   }

//   void _onTurnComplete(
//     _ModelTurnComplete event,
//     Emitter<GeminiLiveState> emit,
//   ) {
//     final updated = _finalizeStreamingMessage(state.messages);
//     emit(state.copyWith(
//       messages: updated,
//       isModelSpeaking: false,
//     ));
//   }

//   // ── Helpers ────────────────────────────────────────────────────────────────
//   List<ChatMessage> _finalizeStreamingMessage(List<ChatMessage> messages) {
//     final list = List<ChatMessage>.from(messages);
//     final idx = list.lastIndexWhere((m) => !m.isUser && m.isStreaming);
//     if (idx != -1) {
//       list[idx] = list[idx].copyWith(isStreaming: false);
//     }
//     return list;
//   }

//   Future<void> _cleanupService() async {
//     await _serviceSub?.cancel();
//     _serviceSub = null;
//     await _service?.dispose();
//     _service = null;
//   }

//   @override
//   Future<void> close() async {
//     await _cleanupService();
//     return super.close();
//   }
// }
