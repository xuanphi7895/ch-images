// ai_speaking_screen.dart
// Full pipeline: STT → Gemini AI (free) → TTS
// ✅ Added: Model selector dropdown in header

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:images/src/utils/api_key_store.dart';
import 'package:images/src/utils/color.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

// ─── Design tokens ────────────────────────────────────
const _purple800 = Color(0xFF3C3489);
const _purple600 = Color(0xFF534AB7);
const _purple200 = Color(0xFFAFA9EC);
const _purple50 = Color(0xFFEEEDFE);
const _teal600 = Color(0xFF0F6E56);
const _teal50 = Color(0xFFE1F5EE);
const _coral600 = Color(0xFF993C1D);
const _coral50 = Color(0xFFFAECE7);
const _amber400 = Color(0xFFEF9F27);
const _amber50 = Color(0xFFFAEEDA);
const _gray50 = Color(0xFFF1EFE8);

// ─────────────────────────────────────────────────────
// GEMINI MODEL DEFINITIONS
// ─────────────────────────────────────────────────────

class GeminiModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String badge; // FREE / LIMITED / PAID
  final Color badgeColor;
  final Color badgeBg;

  const GeminiModel({
    required this.id,
    required this.name,
    required this.description,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
  });

  @override
  List<Object?> get props => [id];
}

const kGeminiModels = [
  GeminiModel(
    id: 'gemini-2.5-flash',
    name: 'Gemini 2.5 Flash',
    description: '15 RPM · 1,000/day — best for this app',
    badge: 'FREE',
    badgeColor: _teal600,
    badgeBg: _teal50,
  ),
  GeminiModel(
    id: 'gemini-2.5-flash-preview-05-20',
    name: 'gemini-2.5-flash-preview-05-20',
    description: '15 RPM · 1,000/day — best for this app',
    badge: 'FREE',
    badgeColor: _teal600,
    badgeBg: _teal50,
  ),
  GeminiModel(
    id: 'gemini-2.5-flash-lite-preview-06-17',
    name: 'Gemini 2.5 Flash-Lite',
    description: '15 RPM · 1,000/day — fastest & lightest',
    badge: 'FREE',
    badgeColor: _teal600,
    badgeBg: _teal50,
  ),
  GeminiModel(
    id: 'gemini-2.5-pro',
    name: 'Gemini 2.5 Pro',
    description: '5 RPM · 50/day — smartest, very limited free',
    badge: 'LIMITED',
    badgeColor: _amber400,
    badgeBg: _amber50,
  ),
  GeminiModel(
    id: 'gemini-3.5-flash',
    name: 'Gemini 3.5 Flash',
    description: 'Newest Flash · paid tier only',
    badge: 'PAID',
    badgeColor: _coral600,
    badgeBg: _coral50,
  ),
  GeminiModel(
    id: 'gemini-3.1-flash-lite',
    name: 'Gemini 3.1 Flash-Lite',
    description: 'Most cost-efficient · paid tier',
    badge: 'PAID',
    badgeColor: _coral600,
    badgeBg: _coral50,
  ),
];

final kDefaultModel = kGeminiModels[0];

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

class SpeakingModelChanged extends SpeakingEvent {
  final GeminiModel model;
  const SpeakingModelChanged(this.model);
  @override
  List<Object?> get props => [model];
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
  final String liveTranscript;
  final List<ChatMessage> messages;
  final GeminiModel selectedModel;
  final String? errorMessage;

  const SpeakingReady({
    required this.step,
    required this.messages,
    required this.selectedModel,
    this.liveTranscript = '',
    this.errorMessage,
  });

  SpeakingReady copyWith({
    PipelineStep? step,
    String? liveTranscript,
    List<ChatMessage>? messages,
    GeminiModel? selectedModel,
    String? errorMessage,
  }) {
    return SpeakingReady(
      step: step ?? this.step,
      liveTranscript: liveTranscript ?? this.liveTranscript,
      messages: messages ?? this.messages,
      selectedModel: selectedModel ?? this.selectedModel,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    step,
    liveTranscript,
    messages,
    selectedModel,
    errorMessage,
  ];
}

// ─────────────────────────────────────────────────────
// GEMINI SERVICE
// ─────────────────────────────────────────────────────

class GeminiService {
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const _systemPrompt = '''
You are an English conversation tutor helping a learner practice speaking.
Rules:
- Keep replies SHORT: 1-3 sentences max.
- Speak naturally, like a real conversation partner.
- If the user makes a grammar mistake, gently correct it at the end of your reply.
- Ask a follow-up question to keep the conversation going.
- Never use bullet points or lists — only natural speech.
''';

  String _currentModel;
  final List<Map<String, dynamic>> _history = [];

  GeminiService(this._currentModel);

  void setModel(String modelId) => _currentModel = modelId;

  Future<String> sendMessage(String userText) async {
    final apiKey = ApiKeyStore.apiKey;
    if (apiKey.isEmpty) {
      throw Exception(
        'Gemini API key is not configured. Please set it in the settings.',
      );
    }

    _history.add({
      'role': 'user',
      'parts': [
        {'text': userText},
      ],
    });

    final url = Uri.parse(
      '$_baseUrl/$_currentModel:generateContent?key=$apiKey',
    );
    print('${url} ${apiKey}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': _systemPrompt},
          ],
        },
        'contents': _history,
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 150,
          'topP': 0.9,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final aiText =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ??
        'Sorry, I could not understand that.';

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
  late final GeminiService _gemini;

  SpeakingBloc() : super(const SpeakingInitial()) {
    _gemini = GeminiService(kDefaultModel.id);
    on<SpeakingInitialized>(_onInitialized);
    on<SpeakingModelChanged>(_onModelChanged);
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

  Future<void> _onInitialized(
    SpeakingInitialized event,
    Emitter<SpeakingState> emit,
  ) async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => add(const SpeakingTtsFinished()));
    _tts.setStartHandler(() => add(const SpeakingTtsStarted()));

    final available = await _stt.initialize(
      onError: (e) => add(SpeakingErrorOccurred(e.errorMsg)),
    );

    if (!available) {
      add(
        const SpeakingErrorOccurred(
          'Speech recognition not available on this device.',
        ),
      );
      return;
    }

    emit(
      SpeakingReady(
        step: PipelineStep.idle,
        selectedModel: kDefaultModel,
        messages: [
          ChatMessage(
            text:
                "Hi! I'm your English conversation partner. "
                "Tap the mic and say something — anything! "
                "I'll reply and help you practice.",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ],
      ),
    );
  }

  // ── NEW: switch model, keep chat history ──
  void _onModelChanged(
    SpeakingModelChanged event,
    Emitter<SpeakingState> emit,
  ) {
    if (state is! SpeakingReady) return;
    _gemini.setModel(event.model.id);
    emit((state as SpeakingReady).copyWith(selectedModel: event.model));
  }

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
        if (result.finalResult) add(const SpeakingRecordStopped());
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 2),
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

    emit(
      s.copyWith(
        step: PipelineStep.processing,
        liveTranscript: '',
        messages: [
          ...s.messages,
          ChatMessage(text: userText, isUser: true, timestamp: DateTime.now()),
        ],
      ),
    );

    add(SpeakingAiRequested(userText));
  }

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
    emit(
      s.copyWith(
        messages: [
          ...s.messages,
          ChatMessage(
            text: event.aiText,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ],
      ),
    );
    await _tts.speak(event.aiText);
  }

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

class AiSpeakingScreenGemini extends StatelessWidget {
  const AiSpeakingScreenGemini({super.key});

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
              child: CircularProgressIndicator(color: _purple600),
            );
          }
          if (state is SpeakingReady) return _ReadyBody(state: state);
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
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(_ReadyBody old) {
    super.didUpdateWidget(old);
    if (widget.state.messages.length != old.state.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return Column(
      children: [
        _Header(state: s),
        if (s.errorMessage != null) _ErrorBanner(message: s.errorMessage!),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount:
                s.messages.length + (s.liveTranscript.isNotEmpty ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == s.messages.length && s.liveTranscript.isNotEmpty) {
                return _LiveTranscriptBubble(text: s.liveTranscript);
              }
              return _ChatBubble(message: s.messages[i]);
            },
          ),
        ),
        _StatusLabel(step: s.step),
        _MicButton(step: s.step),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// HEADER  (with model dropdown)
// ─────────────────────────────────────────────────────

// class _Header extends StatelessWidget {

//   final SpeakingReady state;
//   const _Header({required this.state});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 16,
//         left: 20,
//         right: 20,
//         bottom: 16,
//       ),
//       color: _purple800,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Row 1 — back / title / new chat
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: const Icon(
//                   Icons.arrow_back_ios_new,
//                   color: _purple200,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'AI conversation',
//                       style: TextStyle(
//                         color: Color(0xFFEEEDFE),
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       'Speaking practice',
//                       style: TextStyle(color: _purple200, fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () =>
//                     context.read<SpeakingBloc>().add(const SpeakingRestarted()),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(99),
//                   ),
//                   child: const Row(
//                     children: [
//                       Icon(Icons.refresh, color: _purple200, size: 15),
//                       SizedBox(width: 4),
//                       Text(
//                         'New chat',
//                         style: TextStyle(color: _purple200, fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 12),

//           // Row 2 — model dropdown
//           _ModelDropdown(selectedModel: state.selectedModel),
//         ],
//       ),
//     );
//   }
// }
// class _Header extends StatefulWidget {
//   final SpeakingReady state;

//   const _Header({super.key, required this.state});

//   @override
//   State<_Header> createState() => _HeaderState();
// }

class _Header extends StatefulWidget {
  final SpeakingReady state;
  const _Header({super.key, required this.state});

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  Future<void> _openApiKeySettings() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => const _ApiKeyDialog(),
    );

    if (changed == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_purple800, _purple600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: _purple200,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Conversation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Speaking practice',
                              style: TextStyle(color: _purple200, fontSize: 12),
                            ),
                            const SizedBox(width: 10),
                            _ApiKeyStatusBadge(onTap: _openApiKeySettings),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _HeaderActionButton(
                    icon: Icons.refresh,
                    label: 'New chat',
                    onTap: () => context.read<SpeakingBloc>().add(
                      const SpeakingRestarted(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ModelDropdown(selectedModel: widget.state.selectedModel),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApiKeyDialog extends StatefulWidget {
  const _ApiKeyDialog();

  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ApiKeyStore.apiKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gemini API Key'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Paste your API key',
          helperText: 'Get it from AI Studio',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await ApiKeyStore.save('');
            if (mounted) Navigator.pop(context, true);
          },
          child: const Text('Clear', style: TextStyle(color: Colors.red)),
        ),
        FilledButton(
          onPressed: () async {
            await ApiKeyStore.save(_controller.text);
            if (mounted) Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ApiKeyStatusBadge extends StatelessWidget {
  final VoidCallback onTap;
  const _ApiKeyStatusBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasKey = ApiKeyStore.hasApiKey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: hasKey ? _teal600 : _coral600, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasKey
                  ? Icons.vpn_key_outlined
                  : Icons.no_encryption_gmailerrorred_outlined,
              size: 10,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              hasKey ? 'Key Configured' : 'Setup Key',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────────────
// MODEL DROPDOWN
// ─────────────────────────────────────────────────────

class _ModelDropdown extends StatelessWidget {
  final GeminiModel selectedModel;
  const _ModelDropdown({required this.selectedModel});

  Color _badgeTextColor(GeminiModel m) {
    if (m.badge == 'FREE') return const Color(0xFF9FE1CB);
    if (m.badge == 'LIMITED') return _amber400;
    return const Color(0xFFF0997B);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GeminiModel>(
          value: selectedModel,
          isExpanded: true,
          dropdownColor: const Color(0xFF2E2870),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: _purple200,
            size: 20,
          ),

          // ── What shows in the header (collapsed) ──
          selectedItemBuilder: (_) => kGeminiModels.map((m) {
            return Row(
              children: [
                const Icon(
                  Icons.smart_toy_outlined,
                  color: _purple200,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  m.name,
                  style: const TextStyle(
                    color: Color(0xFFEEEDFE),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: m.badgeBg.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    m.badge,
                    style: TextStyle(
                      fontSize: 10,
                      color: _badgeTextColor(m),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),

          // ── Dropdown menu items ──
          items: kGeminiModels.map((m) {
            final isSelected = m.id == selectedModel.id;
            return DropdownMenuItem<GeminiModel>(
              value: m,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                m.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: const Color(0xFFEEEDFE),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: m.badgeBg.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Text(
                                  m.badge,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: _badgeTextColor(m),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m.description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _purple200,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check, color: _purple200, size: 16),
                  ],
                ),
              ),
            );
          }).toList(),

          onChanged: (m) {
            if (m != null) {
              context.read<SpeakingBloc>().add(SpeakingModelChanged(m));
            }
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// CHAT BUBBLES
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
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: _purple50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: _purple600,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? _purple600 : _gray50,
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
                color: _purple600.withOpacity(0.4),
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
// STATUS LABEL + MIC BUTTON
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
        return _coral600;
      case PipelineStep.processing:
        return _purple600;
      case PipelineStep.speaking:
        return _teal600;
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
              _isListening
                  ? bloc.add(const SpeakingRecordStopped())
                  : bloc.add(const SpeakingRecordStarted());
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
              ? _coral600
              : _purple600,
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
        color: _coral50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _coral600.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _coral600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 13, color: _coral600),
            ),
          ),
        ],
      ),
    );
  }
}
