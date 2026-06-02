import 'package:flutter/material.dart';
import 'package:images/src/modules/features/ipa/presentation/screens/ipa_screen.dart';
import 'package:images/src/modules/features/pdf/screens/pdf_to_tts_screen.dart';
import 'package:images/src/modules/lesson/screens/lesson_screen.dart';

class TopicListScreen extends StatelessWidget {
  const TopicListScreen({super.key});

  static const topics = [
    _Topic(
      'ipa',
      'IPA Chart',
      '44 sounds',
      Icons.work_rounded,
      Color.fromRGBO(5, 196, 64, 46),
    ),
    _Topic(
      'grammar',
      'Grammar',
      '12 lessons',
      Icons.auto_stories,
      Color.fromARGB(255, 138, 231, 138),
    ),
    _Topic('vocab', 'Vocabulary', '24 lessons', Icons.abc, Color(0xFFF59E0B)),
    _Topic(
      'listen',
      'Listening',
      '8 lessons',
      Icons.headphones,
      Color(0xFFEC4899),
    ),
    _Topic('read', 'Reading', '16 lessons', Icons.read_more, Color(0xFF10B981)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final t = topics[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: t.color.withValues(alpha: 0.2),
                child: Icon(t.icon, color: t.color),
              ),
              title: Text(
                t.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(t.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (_) => LessonScreen(topicId: t.id, title: t.title),
                  builder: (_) =>
                      // how to pass topic id to lesson screen? should i use named routes or just pass it through constructor?
                      t.id == 'read'
                      ? PdfToTtsPage()
                      : t.id == 'ipa'
                      ? IpaChartPage()
                      : LessonScreen(
                          topicId: t.id,
                          title: t.title,
                          text:
                              'We use the present simple for habits and facts.\n\n• I work every day.\n• She speaks English.',
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Topic {
  const _Topic(this.id, this.title, this.subtitle, this.icon, this.color);
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

//Angular and Stripe payments integration
