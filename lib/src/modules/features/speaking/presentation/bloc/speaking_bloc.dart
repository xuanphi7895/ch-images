// ═══════════════════════════════════════════
// BLOC
// ═══════════════════════════════════════════
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:equatable/equatable.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:images/src/modules/features/speaking/data/speaking_models.dart';
// import 'package:images/src/modules/features/speaking/domain/speaking_service.dart';
import 'package:images/src/modules/features/speaking/presentation/bloc/speaking_event.dart';
import 'package:images/src/modules/features/speaking/presentation/bloc/speaking_state.dart';

class SpeakingBloc extends Bloc<SpeakingEvent, SpeakingState> {
  final _stt = SpeechToText();
  final _tts = FlutterTts();
  final _gemini = _GeminiSpeakingService();
  final _startTime = DateTime.now();

  static const _scenarios = [
    SpeakingScenarioData(
      id: 's1',
      scenario: SpeakingScenario.jobInterview,
      title: 'Job interview',
      description: 'Practice answering common interview questions in English.',
      aiRole: 'Interviewer',
      userRole: 'Job applicant',
      openingLine:
          "Good morning! Please take a seat. Can you start by telling me a little about yourself and your experience?",
      difficulty: SpeakingDifficulty.intermediate,
      estimatedMinutes: 5,
      xpReward: 80,
      targetPhrases: [
        'I have experience in',
        'I am responsible for',
        'My strengths are',
        'I am passionate about',
      ],
    ),
    SpeakingScenarioData(
      id: 's2',
      scenario: SpeakingScenario.airportCheckin,
      title: 'Airport check-in',
      description: 'Check in for a flight and handle baggage questions.',
      aiRole: 'Check-in agent',
      userRole: 'Passenger',
      openingLine:
          "Good morning! Welcome to EasyFly Airways. May I see your passport and booking reference, please?",
      difficulty: SpeakingDifficulty.beginner,
      estimatedMinutes: 3,
      xpReward: 50,
      targetPhrases: [
        'I would like a window seat',
        'I have one checked bag',
        'What time does boarding begin',
        'Is the flight on time',
      ],
    ),
    SpeakingScenarioData(
      id: 's3',
      scenario: SpeakingScenario.restaurantOrder,
      title: 'Restaurant order',
      description: 'Order food, ask about the menu and make special requests.',
      aiRole: 'Waiter',
      userRole: 'Customer',
      openingLine:
          "Good evening and welcome! Here is your menu. Can I start you off with something to drink?",
      difficulty: SpeakingDifficulty.beginner,
      estimatedMinutes: 4,
      xpReward: 50,
      targetPhrases: [
        'I would like to order',
        'What do you recommend',
        'Does this dish contain',
        'Could I have the bill please',
      ],
    ),
    SpeakingScenarioData(
      id: 's4',
      scenario: SpeakingScenario.hotelBooking,
      title: 'Hotel check-in',
      description:
          'Check into a hotel, ask about facilities and resolve issues.',
      aiRole: 'Hotel receptionist',
      userRole: 'Guest',
      openingLine:
          "Welcome to The Grand Hotel! Do you have a reservation with us?",
      difficulty: SpeakingDifficulty.intermediate,
      estimatedMinutes: 4,
      xpReward: 60,
      targetPhrases: [
        'I have a reservation under',
        'Is breakfast included',
        'Could you recommend',
        'What time is checkout',
      ],
    ),
    SpeakingScenarioData(
      id: 's5',
      scenario: SpeakingScenario.doctorVisit,
      title: 'Doctor visit',
      description: 'Describe symptoms, understand medical advice.',
      aiRole: 'Doctor',
      userRole: 'Patient',
      openingLine:
          "Hello, please come in and sit down. What brings you in today?",
      difficulty: SpeakingDifficulty.advanced,
      estimatedMinutes: 5,
      xpReward: 80,
      targetPhrases: [
        'I have been feeling',
        'The pain started',
        'I am allergic to',
        'How long should I take',
      ],
    ),
  ];

  SpeakingBloc() : super(const SpeakingInitial()) {
    on<SpeakingScreenLoaded>(_onLoaded);
    on<SpeakingScenarioSelected>(_onScenarioSelected);
    on<SpeakingMicPressed>(_onMicPressed);
    on<SpeakingMicReleased>(_onMicReleased);
    on<SpeakingWordDetected>(_onWordDetected);
    on<SpeakingSubmitted>(_onSubmitted);
    on<SpeakingAiReplied>(_onAiReplied);
    on<SpeakingTtsFinished>(_onTtsFinished);
    on<SpeakingFeedbackToggled>(_onFeedbackToggled);
    on<SpeakingHintRequested>(_onHintRequested);
    on<SpeakingSessionEnded>(_onSessionEnded);
    on<SpeakingRestarted>(_onRestarted);
    on<SpeakingErrorOccurred>(_onError);
  }

  Future<void> _onLoaded(
    SpeakingScreenLoaded event,
    Emitter<SpeakingState> emit,
  ) async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => add(const SpeakingTtsFinished()));

    await _stt.initialize(
      onError: (e) => add(SpeakingErrorOccurred(e.errorMsg)),
    );

    emit(SpeakingScenarioPicker(scenarios: _scenarios));
  }

  Future<void> _onScenarioSelected(
    SpeakingScenarioSelected event,
    Emitter<SpeakingState> emit,
  ) async {
    _gemini.clearHistory();

    final openingTurn = SpeakingTurn(
      id: 'ai_0',
      role: TurnRole.ai,
      text: event.scenario.openingLine,
      timestamp: DateTime.now(),
    );

    emit(
      SpeakingConversation(
        scenario: event.scenario,
        status: SpeakingStatus.idle,
        turns: [openingTurn],
      ),
    );

    await _tts.speak(event.scenario.openingLine);
  }

  Future<void> _onMicPressed(
    SpeakingMicPressed event,
    Emitter<SpeakingState> emit,
  ) async {
    if (state is! SpeakingConversation) return;
    final s = state as SpeakingConversation;
    if (s.status != SpeakingStatus.idle) return;

    emit(
      s.copyWith(
        status: SpeakingStatus.recording,
        liveTranscript: '',
        clearError: true,
        clearHint: true,
      ),
    );

    await _stt.listen(
      onResult: (result) {
        add(SpeakingWordDetected(result.recognizedWords));
        if (result.finalResult) add(const SpeakingMicReleased());
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
    if (state is SpeakingConversation) {
      emit(
        (state as SpeakingConversation).copyWith(liveTranscript: event.text),
      );
    }
  }

  Future<void> _onMicReleased(
    SpeakingMicReleased event,
    Emitter<SpeakingState> emit,
  ) async {
    if (state is! SpeakingConversation) return;
    final s = state as SpeakingConversation;

    await _stt.stop();
    final text = s.liveTranscript.trim();
    if (text.isEmpty) {
      emit(s.copyWith(status: SpeakingStatus.idle, liveTranscript: ''));
      return;
    }

    add(SpeakingSubmitted(text));
  }

  Future<void> _onSubmitted(
    SpeakingSubmitted event,
    Emitter<SpeakingState> emit,
  ) async {
    if (state is! SpeakingConversation) return;
    final s = state as SpeakingConversation;

    final userTurn = SpeakingTurn(
      id: 'user_${s.userTurnCount}',
      role: TurnRole.user,
      text: event.text,
      timestamp: DateTime.now(),
    );

    emit(
      s.copyWith(
        status: SpeakingStatus.processing,
        liveTranscript: '',
        turns: [...s.turns, userTurn],
      ),
    );

    try {
      final result = await _gemini.sendTurn(
        scenario: s.scenario,
        userText: event.text,
      );

      final fb = _parseFeedback(result['feedback'] as Map<String, dynamic>);
      final aiText = result['reply'] as String? ?? 'I see, please continue.';

      add(SpeakingAiReplied(aiText, fb));
    } catch (e) {
      add(SpeakingErrorOccurred('AI error: $e'));
    }
  }

  Future<void> _onAiReplied(
    SpeakingAiReplied event,
    Emitter<SpeakingState> emit,
  ) async {
    if (state is! SpeakingConversation) return;
    final s = state as SpeakingConversation;

    // Attach feedback to last user turn
    final turns = s.turns.map((t) {
      if (t.role == TurnRole.user &&
          t.feedback == null &&
          t.id == s.turns.lastWhere((x) => x.role == TurnRole.user).id) {
        return t.withFeedback(event.feedback);
      }
      return t;
    }).toList();

    // Add AI turn
    final aiTurn = SpeakingTurn(
      id: 'ai_${s.userTurnCount}',
      role: TurnRole.ai,
      text: event.aiText,
      timestamp: DateTime.now(),
    );

    emit(
      s.copyWith(status: SpeakingStatus.aiSpeaking, turns: [...turns, aiTurn]),
    );

    await _tts.speak(event.aiText);
  }

  void _onTtsFinished(SpeakingTtsFinished event, Emitter<SpeakingState> emit) {
    if (state is SpeakingConversation) {
      emit(
        (state as SpeakingConversation).copyWith(status: SpeakingStatus.idle),
      );
    }
  }

  void _onFeedbackToggled(
    SpeakingFeedbackToggled event,
    Emitter<SpeakingState> emit,
  ) {
    if (state is! SpeakingConversation) return;
    final s = state as SpeakingConversation;
    final same = s.expandedFeedbackTurnId == event.turnId;
    emit(
      s.copyWith(
        expandedFeedbackTurnId: same ? null : event.turnId,
        clearExpanded: same,
      ),
    );
  }

  Future<void> _onHintRequested(
    SpeakingHintRequested event,
    Emitter<SpeakingState> emit,
  ) async {
    if (state is! SpeakingConversation) return;
    final s = state as SpeakingConversation;

    try {
      final hint = await _gemini.getHint(scenario: s.scenario, turns: s.turns);
      emit(s.copyWith(hint: hint));
    } catch (_) {
      emit(s.copyWith(hint: 'Try responding to what was just said!'));
    }
  }

  void _onSessionEnded(
    SpeakingSessionEnded event,
    Emitter<SpeakingState> emit,
  ) {
    if (state is! SpeakingConversation) return;
    final s = state as SpeakingConversation;

    final userTurns = s.turns
        .where((t) => t.role == TurnRole.user && t.feedback != null)
        .toList();

    if (userTurns.isEmpty) {
      emit(SpeakingScenarioPicker(scenarios: _scenarios));
      return;
    }

    int sumP = 0, sumG = 0, sumV = 0, sumF = 0;
    for (final t in userTurns) {
      sumP += t.feedback!.pronunciationScore;
      sumG += t.feedback!.grammarScore;
      sumV += t.feedback!.vocabularyScore;
      sumF += t.feedback!.fluencyScore;
    }

    final n = userTurns.length;
    final duration = DateTime.now().difference(_startTime).inSeconds;

    emit(
      SpeakingDone(
        scenario: s.scenario,
        result: SpeakingResult(
          scenarioId: s.scenario.id,
          totalTurns: n,
          avgPronunciation: sumP ~/ n,
          avgGrammar: sumG ~/ n,
          avgVocabulary: sumV ~/ n,
          avgFluency: sumF ~/ n,
          xpEarned: (s.scenario.xpReward * (n / 5).clamp(0.2, 1.0)).round(),
          durationSeconds: duration,
          usedTargetPhrases: [],
        ),
      ),
    );
  }

  void _onRestarted(SpeakingRestarted event, Emitter<SpeakingState> emit) {
    emit(SpeakingScenarioPicker(scenarios: _scenarios));
  }

  void _onError(SpeakingErrorOccurred event, Emitter<SpeakingState> emit) {
    if (state is SpeakingConversation) {
      emit(
        (state as SpeakingConversation).copyWith(
          status: SpeakingStatus.idle,
          errorMessage: event.message,
        ),
      );
    }
  }

  SpeakingFeedback _parseFeedback(Map<String, dynamic> fb) {
    final issues = (fb['issues'] as List<dynamic>? ?? []).map((i) {
      final m = i as Map<String, dynamic>;
      return FeedbackItem(
        type: _parseFeedbackType(m['type'] as String? ?? 'grammar'),
        issue: m['issue'] as String? ?? '',
        suggestion: m['suggestion'] as String? ?? '',
      );
    }).toList();

    return SpeakingFeedback(
      pronunciationScore: fb['pronunciation_score'] as int? ?? 75,
      grammarScore: fb['grammar_score'] as int? ?? 75,
      vocabularyScore: fb['vocabulary_score'] as int? ?? 75,
      fluencyScore: fb['fluency_score'] as int? ?? 75,
      correctedText: fb['corrected_text'] as String? ?? '',
      nativeSuggestion: fb['native_suggestion'] as String? ?? '',
      items: issues,
    );
  }

  FeedbackType _parseFeedbackType(String s) {
    switch (s) {
      case 'pronunciation':
        return FeedbackType.pronunciation;
      case 'vocabulary':
        return FeedbackType.vocabulary;
      case 'fluency':
        return FeedbackType.fluency;
      default:
        return FeedbackType.grammar;
    }
  }

  @override
  Future<void> close() async {
    await _stt.stop();
    await _tts.stop();
    super.close();
  }
}

class _GeminiSpeakingService {
  static const _apiKey = '';
  static const _model = 'gemini-2.5-flash';
  static const _base =
      'https://generativelanguage.googleapis.com/v1beta/models';

  final List<Map<String, dynamic>> _history = [];

  Future<Map<String, dynamic>> sendTurn({
    required SpeakingScenarioData scenario,
    required String userText,
  }) async {
    _history.add({
      'role': 'user',
      'parts': [
        {'text': userText},
      ],
    });

    final systemPrompt =
        '''
You are roleplaying as "${scenario.aiRole}" in a "${scenario.title}" scenario.
The user is practicing English as a learner.
 
Your tasks each turn:
1. Reply naturally as ${scenario.aiRole} — keep it 1-3 sentences.
2. Evaluate the user's English and return a JSON feedback object.
 
IMPORTANT: Respond ONLY with this exact JSON format, nothing else:
{
  "reply": "Your natural reply here as ${scenario.aiRole}",
  "feedback": {
    "pronunciation_score": 85,
    "grammar_score": 70,
    "vocabulary_score": 80,
    "fluency_score": 75,
    "corrected_text": "Corrected version of what user said",
    "native_suggestion": "How a native speaker might say it",
    "issues": [
      {"type": "grammar", "issue": "Missing article", "suggestion": "Use 'a' before 'job'"}
    ]
  }
}
Scores are integers 0-100. issues array can be empty if no problems.
feedback.type must be one of: pronunciation, grammar, vocabulary, fluency
''';

    final url = Uri.parse('$_base/$_model:generateContent?key=$_apiKey');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'contents': _history,
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 400},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini error ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final raw =
        data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ??
        '{}';

    // Strip markdown code fences if present
    final clean = raw.replaceAll('```json', '').replaceAll('```', '').trim();

    final parsed = jsonDecode(clean) as Map<String, dynamic>;

    // Add AI reply to history
    _history.add({
      'role': 'model',
      'parts': [
        {'text': parsed['reply'] ?? ''},
      ],
    });

    return parsed;
  }

  Future<String> getHint({
    required SpeakingScenarioData scenario,
    required List<SpeakingTurn> turns,
  }) async {
    final url = Uri.parse('$_base/$_model:generateContent?key=$_apiKey');
    final context = turns.map((t) => '${t.role.name}: ${t.text}').join('\n');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {
                'text':
                    'Scenario: ${scenario.title}\nConversation so far:\n$context\n\n'
                    'Give a short 1-sentence hint on what the learner could say next. '
                    'Write it naturally as a suggestion, e.g. "You could say: ..."',
              },
            ],
          },
        ],
        'generationConfig': {'temperature': 0.5, 'maxOutputTokens': 80},
      }),
    );

    if (response.statusCode != 200) return 'Try responding naturally!';

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['candidates']?[0]?['content']?['parts']?[0]?['text']
            as String? ??
        'Try responding naturally!';
  }

  void clearHistory() => _history.clear();
}
