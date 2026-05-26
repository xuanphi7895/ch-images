import 'package:flutter/material.dart';
import 'package:images/src/modules/quiz/screens/quiz_screen.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.topicId, required this.title});
  final String topicId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 140,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.play_circle_fill,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Present simple',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We use the present simple for habits and facts.\n\n'
            '• I work every day.\n'
            '• She speaks English.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuizScreen(topicId: topicId)),
            ),
            icon: const Icon(Icons.quiz),
            label: const Text('Start quiz'),
          ),
        ],
      ),
    );
  }
}
