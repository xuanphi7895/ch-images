// ═══════════════════════════════════════════
// GEMINI SERVICE  (feedback + reply)
// ═══════════════════════════════════════════
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:images/src/modules/features/speaking/data/speaking_models.dart';

class _GeminiSpeakingService {
  static const _apiKey = 'YOUR_GEMINI_API_KEY';
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
