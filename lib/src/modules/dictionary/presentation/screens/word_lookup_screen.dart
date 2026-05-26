import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:images/src/modules/dictionary/data/dictionary_api.dart';

import '../widgets/dictionary_info_card.dart';

class WordLookupScreen extends StatelessWidget {
  const WordLookupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const WordLookupPage(),
    );
  }
}

class WordLookupPage extends StatefulWidget {
  const WordLookupPage({super.key});

  @override
  State<WordLookupPage> createState() => _WordLookupPageState();
}

class _WordLookupPageState extends State<WordLookupPage> {
  final _controller = TextEditingController(text: 'hello');
  Dictionary? _entry;
  String? _error;
  bool _loading = false;

  Future<void> _search() async {
    final word = _controller.text.trim();
    if (word.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _entry = null;
    });

    try {
      final uri = Uri.parse(
        'https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(word)}',
      );
      final res = await http.get(uri);
      print(res.body);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        final entry = Dictionary.fromJson(list.first as Map<String, dynamic>);

        setState(() => _entry = entry);
      } else if (res.statusCode == 404) {
        setState(() => _error = 'Word not found.');
      } else {
        setState(() => _error = 'Error ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dictionary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Word',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _search,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Search'),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (_entry != null) DictionaryInfoCard(entry: _entry!),
        ],
      ),
    );
  }
}
