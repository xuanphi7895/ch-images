import 'dart:convert';

import 'package:http/http.dart' as http;

class DictionaryRepository {
  DictionaryRepository({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<dynamic>> fetchEntry(String word) async {
    final w = Uri.encodeComponent(word.trim());
    final uri = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$w');
    final res = await _client.get(uri);

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    if (res.statusCode == 404) {
      throw StateError('Word not found');
    }
    throw StateError('HTTP ${res.statusCode}');
  }
}
