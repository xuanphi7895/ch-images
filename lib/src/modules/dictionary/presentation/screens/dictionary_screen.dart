import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:images/src/modules/dictionary/data/dictionary_repository.dart';
import 'package:images/src/modules/dictionary/presentation/bloc/dictionary_bloc.dart';
import 'package:images/src/modules/dictionary/presentation/bloc/dictionary_event.dart';
import 'package:images/src/modules/dictionary/presentation/bloc/dictionary_state.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dictionary BLoC',
      home: BlocProvider(
        create: (_) => DictionaryBloc(repository: DictionaryRepository()),
        child: const DictionaryPage(),
      ),
    );
  }
}

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final _controller = TextEditingController(text: 'hello');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fetch() {
    context.read<DictionaryBloc>().add(
      DictionaryLoadRequested(_controller.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLoC + dictionaryapi.dev')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'English word',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _fetch(),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _fetch, child: const Text('Load')),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<DictionaryBloc, DictionaryState>(
                builder: (context, state) {
                  return switch (state) {
                    DictionaryInitial() => const Center(
                      child: Text('Tap Load to call the API.'),
                    ),
                    DictionaryLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    DictionaryLoaded(:final json) => SingleChildScrollView(
                      child: Text(json.toString()),
                    ),
                    DictionaryError(:final message) => Center(
                      child: Text(message),
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
