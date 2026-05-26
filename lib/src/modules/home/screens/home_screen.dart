// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// // void main() {
// //   runApp(const EnglishFlowApp());
// // }

// // --- fake content (replace with your models / API later) ---

// class Topic {
//   const Topic({required this.id, required this.title});
//   final String id;
//   final String title;
// }

// class Lesson {
//   const Lesson({required this.id, required this.title, required this.topicId});
//   final String id;
//   final String title;
//   final String topicId;
// }

// const topics = <Topic>[
//   Topic(id: 'grammar', title: 'Grammar'),
//   Topic(id: 'vocab', title: 'Vocabulary'),
// ];

// Lesson? lessonByIds(String topicId, String lessonId) {
//   const lessons = <Lesson>[
//     Lesson(id: 'l1', title: 'Present simple', topicId: 'grammar'),
//     Lesson(id: 'l2', title: 'Articles (a / the)', topicId: 'grammar'),
//     Lesson(id: 'l3', title: 'Food words', topicId: 'vocab'),
//   ];
//   for (final l in lessons) {
//     if (l.topicId == topicId && l.id == lessonId) return l;
//   }
//   return null;
// }

// // --- app + router ---

// class EnglishFlowApp extends StatelessWidget {
//   const EnglishFlowApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'English flow demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
//         useMaterial3: true,
//       ),
//       routerConfig: _router,
//     );
//   }
// }

// final GoRouter _router = GoRouter(
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (context, state) => const HomeScreen(),
//       routes: [
//         GoRoute(
//           path: 'topics',
//           builder: (context, state) => const TopicListScreen(),
//           routes: [
//             GoRoute(
//               path: ':topicId/lessons/:lessonId',
//               builder: (context, state) {
//                 final topicId = state.pathParameters['topicId']!;
//                 final lessonId = state.pathParameters['lessonId']!;
//                 return LessonScreen(topicId: topicId, lessonId: lessonId);
//               },
//               routes: [
//                 GoRoute(
//                   path: 'quiz',
//                   builder: (context, state) {
//                     final topicId = state.pathParameters['topicId']!;
//                     final lessonId = state.pathParameters['lessonId']!;
//                     return QuizScreen(topicId: topicId, lessonId: lessonId);
//                   },
//                 ),
//                 GoRoute(
//                   path: 'results',
//                   builder: (context, state) {
//                     final score = state.uri.queryParameters['score'] ?? '0';
//                     final total = state.uri.queryParameters['total'] ?? '0';
//                     return ResultsScreen(
//                       score: int.tryParse(score) ?? 0,
//                       total: int.tryParse(total) ?? 0,
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     ),
//   ],
// );

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home')),
//       body: Center(
//         child: FilledButton(
//           onPressed: () => context.go('/topics'),
//           child: const Text('Browse topics'),
//         ),
//       ),
//     );
//   }
// }

// class TopicListScreen extends StatelessWidget {
//   const TopicListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Topics')),
//       body: ListView.separated(
//         itemCount: topics.length,
//         separatorBuilder: (_, __) => const Divider(height: 1),
//         itemBuilder: (context, index) {
//           final t = topics[index];
//           // Demo: first lesson per topic — in a real app, list lessons from data
//           final firstLessonId = t.id == 'grammar' ? 'l1' : 'l3';
//           return ListTile(
//             title: Text(t.title),
//             subtitle: Text('Topic id: ${t.id}'),
//             trailing: const Icon(Icons.chevron_right),
//             onTap: () => context.go('/topics/${t.id}/lessons/$firstLessonId'),
//           );
//         },
//       ),
//     );
//   }
// }

// class LessonScreen extends StatelessWidget {
//   const LessonScreen({
//     super.key,
//     required this.topicId,
//     required this.lessonId,
//   });

//   final String topicId;
//   final String lessonId;

//   @override
//   Widget build(BuildContext context) {
//     final lesson = lessonByIds(topicId, lessonId);
//     final title = lesson?.title ?? 'Unknown lesson';

//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Topic: $topicId',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'This is where your explanation, audio, or reading passage would go.',
//             ),
//             const Spacer(),
//             FilledButton(
//               onPressed: () =>
//                   context.go('/topics/$topicId/lessons/$lessonId/quiz'),
//               child: const Text('Start quiz'),
//             ),
//             OutlinedButton(
//               onPressed: () => context.go('/topics'),
//               child: const Text('Back to topics'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class QuizScreen extends StatefulWidget {
//   const QuizScreen({super.key, required this.topicId, required this.lessonId});

//   final String topicId;
//   final String lessonId;

//   @override
//   State<QuizScreen> createState() => _QuizScreenState();
// }

// class _QuizScreenState extends State<QuizScreen> {
//   static const _questions = <_Question>[
//     _Question('She ___ to school every day.', ['go', 'goes', 'going'], 1),
//     _Question('I need ___ apple.', ['a', 'an', 'the'], 1),
//   ];

//   final List<int?> _answers = List<int?>.filled(_questions.length, null);

//   int get _score {
//     var s = 0;
//     for (var i = 0; i < _questions.length; i++) {
//       if (_answers[i] == _questions[i].correctIndex) s++;
//     }
//     return s;
//   }

//   void _submit() {
//     final unanswered = _answers.contains(null);
//     if (unanswered) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Answer all questions first.')),
//       );
//       return;
//     }
//     final score = _score;
//     context.go(
//       '/topics/${widget.topicId}/lessons/${widget.lessonId}/results'
//       '?score=$score&total=${_questions.length}',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Quiz')),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           for (var i = 0; i < _questions.length; i++) ...[
//             Text(
//               'Q${i + 1}. ${_questions[i].prompt}',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             ...List.generate(_questions[i].choices.length, (c) {
//               return RadioListTile<int>(
//                 title: Text(_questions[i].choices[c]),
//                 value: c,
//                 groupValue: _answers[i],
//                 onChanged: (v) => setState(() => _answers[i] = v),
//               );
//             }),
//             const SizedBox(height: 16),
//           ],
//           FilledButton(onPressed: _submit, child: const Text('See results')),
//         ],
//       ),
//     );
//   }
// }

// class _Question {
//   const _Question(this.prompt, this.choices, this.correctIndex);
//   final String prompt;
//   final List<String> choices;
//   final int correctIndex;
// }

// class ResultsScreen extends StatelessWidget {
//   const ResultsScreen({super.key, required this.score, required this.total});

//   final int score;
//   final int total;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Results')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'You scored $score / $total',
//               style: Theme.of(context).textTheme.headlineSmall,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             FilledButton(
//               onPressed: () {
//                 // "Retry" — same quiz URL
//                 final uri = GoRouterState.of(context).uri;
//                 final parts = uri.pathSegments;
//                 // path: topics / :topicId / lessons / :lessonId / results
//                 final topicId = parts[1];
//                 final lessonId = parts[3];
//                 context.go('/topics/$topicId/lessons/$lessonId/quiz');
//               },
//               child: const Text('Retry quiz'),
//             ),
//             const SizedBox(height: 8),
//             OutlinedButton(
//               onPressed: () => context.go('/topics'),
//               child: const Text('Back to topics'),
//             ),
//             const SizedBox(height: 8),
//             TextButton(
//               onPressed: () => context.go('/'),
//               child: const Text('Home'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Good morning 👋',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Keep your streak!',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _StreakCard(streak: 5, cs: cs),
            const SizedBox(height: 20),
            Text('Continue', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _ContinueCard(
              title: 'Present simple',
              subtitle: 'Grammar · Lesson 2',
              progress: 0.6,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            Text('Quick start', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickTile(
                    icon: Icons.spellcheck,
                    label: 'Vocabulary',
                    color: cs.primaryContainer,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickTile(
                    icon: Icons.headphones,
                    label: 'Listening',
                    color: cs.secondaryContainer,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.streak, required this.cs});
  final int streak;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withValues(alpha: 0.75)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak day streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Practice 10 min today',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: onTap,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              CircleAvatar(backgroundColor: color, child: Icon(icon)),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
