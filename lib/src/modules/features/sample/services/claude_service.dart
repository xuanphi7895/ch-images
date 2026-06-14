import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  // Replace with your Anthropic API key
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY';

  static String _buildSystemPrompt(String topic) {
    return '''You are a warm, encouraging English speaking tutor. Have natural English conversations with learners and help them improve.

Rules:
1. Start by asking a friendly, open-ended question about the chosen topic.
2. After each learner response, reply naturally (1-2 sentences), then give brief feedback:
   ✅ What was good (1 specific thing)
   💡 One gentle suggestion to improve (grammar, vocabulary, or phrasing)
   Then ask a follow-up question to keep the conversation going.
3. Keep your total reply under 120 words.
4. Be encouraging and warm. Never be harsh.
5. If they make a grammar error, show the corrected version naturally (e.g. "You could say: '...'")
6. The topic is: $topic''';
  }

  static Future<String> sendMessage({
    required List<Map<String, String>> messages,
    required String topic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1000,
          'system': _buildSystemPrompt(topic),
          'messages': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error']['message'] ?? 'API error ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect: $e');
    }
  }
}
