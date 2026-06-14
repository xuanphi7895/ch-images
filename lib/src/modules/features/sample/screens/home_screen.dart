import 'package:flutter/material.dart';
import 'chat_screen.dart';

class HomeAIScreen extends StatelessWidget {
  const HomeAIScreen({super.key});

  static const topics = [
    {
      'name': 'Daily Life',
      'icon': Icons.wb_sunny_outlined,
      'color': Color(0xFF185FA5),
    },
    {
      'name': 'Travel',
      'icon': Icons.flight_outlined,
      'color': Color(0xFF0F6E56),
    },
    {
      'name': 'Work & Career',
      'icon': Icons.work_outline,
      'color': Color(0xFF854F0B),
    },
    {
      'name': 'Food & Cooking',
      'icon': Icons.restaurant_outlined,
      'color': Color(0xFF993556),
    },
    {
      'name': 'Hobbies',
      'icon': Icons.sports_esports_outlined,
      'color': Color(0xFF534AB7),
    },
    {
      'name': 'News & Opinions',
      'icon': Icons.newspaper_outlined,
      'color': Color(0xFF993C1D),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF185FA5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.record_voice_over,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'English Tutor AI',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        'Powered by Claude AI',
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text(
                'Choose a topic to practice',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Speak or type — get instant AI feedback',
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: topics.length,
                  itemBuilder: (context, i) {
                    final t = topics[i];
                    return _TopicCard(
                      name: t['name'] as String,
                      icon: t['icon'] as IconData,
                      color: t['color'] as Color,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatScreen(topic: t['name'] as String),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF185FA5),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Add your Anthropic API key in services/claude_service.dart to activate AI responses.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0C447C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TopicCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
