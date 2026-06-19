// ai_speaking_screen.dart
// Full pipeline: STT → Gemini AI (free) → TTS
// Packages needed:
//   speech_to_text: ^6.6.2
//   flutter_tts: ^4.0.2
//   http: ^1.2.1
//   permission_handler: ^11.3.1

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:images/src/utils/color.dart';
// ─── Design tokens ────────────────────────────────────
// const _purple800 = Color(0xFF3C3489);
// const _purple600 = Color(0xFF534AB7);
// const _purple200 = Color(0xFFAFA9EC);
// const _purple50  = Color(0xFFEEEDFE);
// const _teal600   = Color(0xFF0F6E56);
// const _teal50    = Color(0xFFE1F5EE);
// const _coral600  = Color(0xFF993C1D);
// const _coral50   = Color(0xFFFAECE7);
// const _gray50    = Color(0xFFF1EFE8);

// ─────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────

class ChatMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [text, isUser, timestamp];
}

// ─────────────────────────────────────────────────────
// EVENTS
// ─────────────────────────────────────────────────────

abstract class SpeakingEvent extends Equatable {
  const SpeakingEvent();
  @override
  List<Object?> get props => [];
}

class SpeakingInitialized extends SpeakingEvent {
  const SpeakingInitialized();
}

class SpeakingRecordStarted extends SpeakingEvent {
  const SpeakingRecordStarted();
}

class SpeakingRecordStopped extends SpeakingEvent {
  const SpeakingRecordStopped();
}

class SpeakingWordDetected extends SpeakingEvent {
  final String text;
  const SpeakingWordDetected(this.text);
  @override
  List<Object?> get props => [text];
}

class SpeakingAiRequested extends SpeakingEvent {
  final String userText;
  const SpeakingAiRequested(this.userText);
  @override
  List<Object?> get props => [userText];
}

class SpeakingAiReplied extends SpeakingEvent {
  final String aiText;
  const SpeakingAiReplied(this.aiText);
  @override
  List<Object?> get props => [aiText];
}

class SpeakingTtsStarted extends SpeakingEvent {
  const SpeakingTtsStarted();
}

class SpeakingTtsFinished extends SpeakingEvent {
  const SpeakingTtsFinished();
}

class SpeakingErrorOccurred extends SpeakingEvent {
  final String message;
  const SpeakingErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}

class SpeakingRestarted extends SpeakingEvent {
  const SpeakingRestarted();
}

// ─────────────────────────────────────────────────────
// STATES
// ─────────────────────────────────────────────────────

enum PipelineStep { idle, listening, processing, speaking }

abstract class SpeakingState extends Equatable {
  const SpeakingState();
  @override
  List<Object?> get props => [];
}

class SpeakingInitial extends SpeakingState {
  const SpeakingInitial();
}

class SpeakingReady extends SpeakingState {
  final PipelineStep step;
  final String liveTranscript; // words as user speaks
  final List<ChatMessage> messages;
  final String? errorMessage;

  const SpeakingReady({
    required this.step,
    required this.messages,
    this.liveTranscript = '',
    this.errorMessage,
  });

  SpeakingReady copyWith({
    PipelineStep? step,
    String? liveTranscript,
    List<ChatMessage>? messages,
    String? errorMessage,
  }) {
    return SpeakingReady(
      step: step ?? this.step,
      liveTranscript: liveTranscript ?? this.liveTranscript,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [step, liveTranscript, messages, errorMessage];
}

// ─────────────────────────────────────────────────────
// SERVICE — Gemini AI (free tier)
// ─────────────────────────────────────────────────────

class GeminiService {
  // Get free API key at: https://aistudio.google.com/app/apikey
  // Free tier: 15 requests/min, 1M tokens/day — plenty for a language app
  static const _apiKey = '';
  // static const _model = 'gemini-1.5-flash'; // fastest free model
  static const _model = 'gemini-2.5-flash'; // fastest free model
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // System prompt — tuned for English learning
  static const _systemPrompt = '''
You are an English conversation tutor helping a learner practice speaking.
Rules:
- Keep replies SHORT: 1-3 sentences max.
- Speak naturally, like a real conversation partner.
- If the user makes a grammar mistake, gently correct it at the end of your reply.
- Ask a follow-up question to keep the conversation going.
- Never use bullet points or lists — only natural speech.
''';

  final List<Map<String, dynamic>> _history = [];

  Future<String> sendMessage(String userText) async {
    // Add user turn to history
    _history.add({
      'role': 'user',
      'parts': [
        {'text': userText},
      ],
    });

    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$_apiKey');

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
      'contents': _history,
      'generationConfig': {
        'temperature': 0.8,
        'maxOutputTokens': 150, // keep replies short for TTS
        'topP': 0.9,
      },
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final aiText =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ??
        'Sorry, I could not understand that.';

    // Add AI turn to history for multi-turn context
    _history.add({
      'role': 'model',
      'parts': [
        {'text': aiText},
      ],
    });

    return aiText;
  }

  void clearHistory() => _history.clear();
}

// ─────────────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────────────

class SpeakingBloc extends Bloc<SpeakingEvent, SpeakingState> {
  final _stt = SpeechToText();
  final _tts = FlutterTts();
  final _gemini = GeminiService();

  SpeakingBloc() : super(const SpeakingInitial()) {
    on<SpeakingInitialized>(_onInitialized);
    on<SpeakingRecordStarted>(_onRecordStarted);
    on<SpeakingRecordStopped>(_onRecordStopped);
    on<SpeakingWordDetected>(_onWordDetected);
    on<SpeakingAiRequested>(_onAiRequested);
    on<SpeakingAiReplied>(_onAiReplied);
    on<SpeakingTtsStarted>(_onTtsStarted);
    on<SpeakingTtsFinished>(_onTtsFinished);
    on<SpeakingErrorOccurred>(_onError);
    on<SpeakingRestarted>(_onRestarted);
  }

  // ── Init ──────────────────────────────────

  Future<void> _onInitialized(
    SpeakingInitialized event,
    Emitter<SpeakingState> emit,
  ) async {
    // Configure TTS
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45); // slightly slower for clarity
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() => add(const SpeakingTtsFinished()));
    _tts.setStartHandler(() => add(const SpeakingTtsStarted()));

    // Check STT availability
    final available = await _stt.initialize(
      onError: (error) => add(SpeakingErrorOccurred(error.errorMsg)),
    );

    if (!available) {
      add(
        const SpeakingErrorOccurred(
          'Speech recognition not available on this device.',
        ),
      );
      return;
    }

    // Greet the user
    // const greeting = ChatMessage(
    //   text:
    //       "Hi! I'm your English conversation partner. "
    //       "Tap the mic and say something — anything! I'll reply and help you practice.",
    //   isUser: false,
    //   timestamp: DateTime.now(),
    // );

    emit(
      SpeakingReady(
        step: PipelineStep.idle,
        messages: [
          ChatMessage(
            text:
                "Hi! I'm your English conversation partner. "
                "Tap the mic and say something — anything! I'll reply and help you practice.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ],
      ),
    );
  }

  // ── Record ────────────────────────────────

  Future<void> _onRecordStarted(
    SpeakingRecordStarted event,
    Emitter<SpeakingState> emit,
  ) async {
    if (state is! SpeakingReady) return;
    final s = state as SpeakingReady;
    if (s.step != PipelineStep.idle) return;

    emit(s.copyWith(step: PipelineStep.listening, liveTranscript: ''));

    await _stt.listen(
      onResult: (result) {
        add(SpeakingWordDetected(result.recognizedWords));
        // Auto-stop when STT detects end of speech
        if (result.finalResult) add(const SpeakingRecordStopped());
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 2), // auto-stop after 2s silence
      localeId: 'en_US',
      cancelOnError: true,
    );
  }

  void _onWordDetected(
    SpeakingWordDetected event,
    Emitter<SpeakingState> emit,
  ) {
    if (state is SpeakingReady) {
      emit((state as SpeakingReady).copyWith(liveTranscript: event.text));
    }
  }

  Future<void> _onRecordStopped(
    SpeakingRecordStopped event,
    Emitter<SpeakingState> emit,
  ) async {
    if (state is! SpeakingReady) return;
    final s = state as SpeakingReady;

    await _stt.stop();

    final userText = s.liveTranscript.trim();
    if (userText.isEmpty) {
      emit(s.copyWith(step: PipelineStep.idle, liveTranscript: ''));
      return;
    }

    // Add user message to chat
    final updatedMessages = [
      ...s.messages,
      ChatMessage(text: userText, isUser: true, timestamp: DateTime.now()),
    ];

    emit(
      s.copyWith(
        step: PipelineStep.processing,
        liveTranscript: '',
        messages: updatedMessages,
      ),
    );

    add(SpeakingAiRequested(userText));
  }

  // ── AI ────────────────────────────────────

  Future<void> _onAiRequested(
    SpeakingAiRequested event,
    Emitter<SpeakingState> emit,
  ) async {
    try {
      final aiText = await _gemini.sendMessage(event.userText);
      add(SpeakingAiReplied(aiText));
    } catch (e) {
      add(SpeakingErrorOccurred('AI error: ${e.toString()}'));
    }
  }

  Future<void> _onAiReplied(
    SpeakingAiReplied event,
    Emitter<SpeakingState> emit,
  ) async {
    if (state is! SpeakingReady) return;
    final s = state as SpeakingReady;

    final updatedMessages = [
      ...s.messages,
      ChatMessage(text: event.aiText, isUser: false, timestamp: DateTime.now()),
    ];

    emit(s.copyWith(messages: updatedMessages));

    // Speak the AI reply
    await _tts.speak(event.aiText);
  }

  // ── TTS ───────────────────────────────────

  void _onTtsStarted(SpeakingTtsStarted event, Emitter<SpeakingState> emit) {
    if (state is SpeakingReady) {
      emit((state as SpeakingReady).copyWith(step: PipelineStep.speaking));
    }
  }

  void _onTtsFinished(SpeakingTtsFinished event, Emitter<SpeakingState> emit) {
    if (state is SpeakingReady) {
      emit((state as SpeakingReady).copyWith(step: PipelineStep.idle));
    }
  }

  // ── Error / Reset ─────────────────────────

  void _onError(SpeakingErrorOccurred event, Emitter<SpeakingState> emit) {
    if (state is SpeakingReady) {
      emit(
        (state as SpeakingReady).copyWith(
          step: PipelineStep.idle,
          errorMessage: event.message,
        ),
      );
    }
  }

  void _onRestarted(SpeakingRestarted event, Emitter<SpeakingState> emit) {
    _gemini.clearHistory();
    add(const SpeakingInitialized());
  }

  @override
  Future<void> close() async {
    await _stt.stop();
    await _tts.stop();
    super.close();
  }
}

// ─────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────

class AiSpeakingScreen extends StatelessWidget {
  const AiSpeakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SpeakingBloc()..add(const SpeakingInitialized()),
      child: const _SpeakingView(),
    );
  }
}

class _SpeakingView extends StatelessWidget {
  const _SpeakingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<SpeakingBloc, SpeakingState>(
        builder: (context, state) {
          if (state is SpeakingInitial) {
            return const Center(
              child: CircularProgressIndicator(color: CustomColors.Purple600),
            );
          }
          if (state is SpeakingReady) {
            return _ReadyBody(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────

class _ReadyBody extends StatefulWidget {
  final SpeakingReady state;
  const _ReadyBody({required this.state});

  @override
  State<_ReadyBody> createState() => _ReadyBodyState();
}

class _ReadyBodyState extends State<_ReadyBody> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(_ReadyBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.messages.length != oldWidget.state.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final topPad = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        // ── Header ──
        _Header(state: state),

        // ── Error banner ──
        if (state.errorMessage != null)
          _ErrorBanner(message: state.errorMessage!),

        // ── Chat messages ──
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount:
                state.messages.length +
                (state.liveTranscript.isNotEmpty ? 1 : 0),
            itemBuilder: (ctx, i) {
              // Live transcript bubble at the end
              if (i == state.messages.length &&
                  state.liveTranscript.isNotEmpty) {
                return _LiveTranscriptBubble(text: state.liveTranscript);
              }
              return _ChatBubble(message: state.messages[i]);
            },
          ),
        ),

        // ── Status label ──
        _StatusLabel(step: state.step),

        // ── Mic button ──
        _MicButton(step: state.step),

        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final SpeakingReady state;
  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      color: CustomColors.Purple800,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: CustomColors.Purple200,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI conversation',
                  style: TextStyle(
                    color: Color(0xFFEEEDFE),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Speaking practice',
                  style: TextStyle(color: CustomColors.Purple200, fontSize: 12),
                ),
              ],
            ),
          ),
          // Restart button
          GestureDetector(
            onTap: () =>
                context.read<SpeakingBloc>().add(const SpeakingRestarted()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Row(
                children: [
                  Icon(Icons.refresh, color: CustomColors.Purple200, size: 15),
                  SizedBox(width: 4),
                  Text(
                    'New chat',
                    style: TextStyle(
                      color: CustomColors.Purple200,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// CHAT BUBBLE
// ─────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[_AiAvatar(), const SizedBox(width: 8)],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? CustomColors.Purple600 : CustomColors.Gray50,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isUser ? 14 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 14),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: CustomColors.Purple50,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.smart_toy_outlined,
        color: CustomColors.Purple600,
        size: 16,
      ),
    );
  }
}

// Live transcript (semi-transparent, still typing feel)
class _LiveTranscriptBubble extends StatelessWidget {
  final String text;
  const _LiveTranscriptBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: CustomColors.Purple600.withOpacity(0.4),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// STATUS LABEL
// ─────────────────────────────────────────────────────

class _StatusLabel extends StatelessWidget {
  final PipelineStep step;
  const _StatusLabel({required this.step});

  String get _label {
    switch (step) {
      case PipelineStep.idle:
        return 'Tap mic to speak';
      case PipelineStep.listening:
        return 'Listening…';
      case PipelineStep.processing:
        return 'AI is thinking…';
      case PipelineStep.speaking:
        return 'AI is speaking…';
    }
  }

  Color get _color {
    switch (step) {
      case PipelineStep.idle:
        return Colors.black38;
      case PipelineStep.listening:
        return CustomColors.Coral600;
      case PipelineStep.processing:
        return CustomColors.Purple600;
      case PipelineStep.speaking:
        return CustomColors.Teal600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          _label,
          key: ValueKey(step),
          style: TextStyle(
            fontSize: 13,
            color: _color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// MIC BUTTON
// ─────────────────────────────────────────────────────

class _MicButton extends StatelessWidget {
  final PipelineStep step;
  const _MicButton({required this.step});

  bool get _isListening => step == PipelineStep.listening;
  bool get _isDisabled =>
      step == PipelineStep.processing || step == PipelineStep.speaking;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isDisabled
          ? null
          : () {
              final bloc = context.read<SpeakingBloc>();
              if (_isListening) {
                bloc.add(const SpeakingRecordStopped());
              } else {
                bloc.add(const SpeakingRecordStarted());
              }
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isDisabled
              ? Colors.black.withOpacity(0.08)
              : _isListening
              ? CustomColors.Coral600
              : CustomColors.Purple600,
        ),
        child: Icon(
          _isListening ? Icons.stop_rounded : Icons.mic_none_outlined,
          color: _isDisabled ? Colors.black26 : Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// ERROR BANNER
// ─────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: CustomColors.Coral50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: CustomColors.Coral600.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: CustomColors.Coral600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: CustomColors.Coral600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
