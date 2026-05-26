import 'package:flutter/material.dart';
import 'package:images/src/modules/features/results/screens/results_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.topicId});
  final String topicId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _q = 0;
  int? _selected;
  int _score = 0;

  final _questions = const [
    _Q('She ___ to school.', ['go', 'goes', 'going'], 1),
    _Q('They ___ coffee.', ['likes', 'like', 'liking'], 1),
  ];

  void _next() {
    if (_selected == _questions[_q].correct) _score++;
    if (_q + 1 >= _questions.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ResultsScreen(score: _score, total: _questions.length),
        ),
      );
      return;
    }
    setState(() {
      _q++;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_q];
    return Scaffold(
      appBar: AppBar(title: Text('Question ${_q + 1}/${_questions.length}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: (_q + 1) / _questions.length),
            const SizedBox(height: 24),
            Text(q.prompt, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            ...List.generate(q.choices.length, (i) {
              final selected = _selected == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: selected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                  ),
                  onPressed: () => setState(() => _selected = i),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(q.choices[i]),
                  ),
                ),
              );
            }),
            const Spacer(),
            FilledButton(
              onPressed: _selected == null ? null : _next,
              child: Text(_q + 1 >= _questions.length ? 'Finish' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Q {
  const _Q(this.prompt, this.choices, this.correct);
  final String prompt;
  final List<String> choices;
  final int correct;
}
