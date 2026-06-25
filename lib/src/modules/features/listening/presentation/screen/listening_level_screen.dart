import 'package:flutter/material.dart';
import 'package:images/src/modules/features/listening/data/listening_level.dart';

class ListeningLevelsScreen extends StatefulWidget {
  const ListeningLevelsScreen({super.key});

  @override
  State<ListeningLevelsScreen> createState() => _ListeningLevelsScreenState();
}

class _ListeningLevelsScreenState extends State<ListeningLevelsScreen> {
  // Define the configuration for all 7 structural levels
  final List<ListeningLevel> levels = [
    ListeningLevel(
      number: 1,
      title: "Low Beginner",
      progress: 0.8,
      baseColor: Colors.teal[400]!,
      description: "Short phrases, basic greetings, clear accents.",
    ),
    ListeningLevel(
      number: 2,
      title: "Mid Beginner",
      progress: 0.5,
      baseColor: Colors.green[400]!,
      description: "Everyday conversations, simple shopping requests.",
    ),
    ListeningLevel(
      number: 3,
      title: "High Beginner",
      progress: 0.2,
      baseColor: Colors.lightGreen[600]!,
      description: "Simple descriptive stories, asking directions.",
    ),
    ListeningLevel(
      number: 4,
      title: "Low Intermediate",
      progress: 0.0,
      baseColor: Colors.blue[400]!,
      description: "Travel exchanges, weather updates, basic messaging.",
    ),
    ListeningLevel(
      number: 5,
      title: "Mid Intermediate",
      progress: 0.0,
      baseColor: Colors.indigo[400]!,
      description: "Workplace standups, standard news summaries.",
    ),
    ListeningLevel(
      number: 6,
      title: "High Intermediate",
      progress: 0.0,
      baseColor: Colors.deepPurple[400]!,
      description: "Podcasts, casual debates, real conversational tempos.",
    ),
    ListeningLevel(
      number: 7,
      title: "Advanced",
      progress: 0.0,
      baseColor: Colors.red[400]!,
      description:
          "Native idioms, fast-paced technical lectures, multi-speaker interviews.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Listening Training",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  // Standard routing mechanism passing the selected level down the tree
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LevelDetailScreen(level: level),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Circular Level Accent Indicator badge
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: level.baseColor.withOpacity(0.15),
                        child: Text(
                          "L${level.number}",
                          style: TextStyle(
                            color: level.baseColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Text Identifiers and Progress Elements
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              level.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              level.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Level Completion Progress Indicator row
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: level.progress,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      level.baseColor,
                                    ),
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "${(level.progress * 100).toInt()}%",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[400],
                        size: 16,
                      ),
                    ],
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

// 2. The Destination Screen loaded dynamically per chosen element
class LevelDetailScreen extends StatelessWidget {
  final ListeningLevel level;

  const LevelDetailScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(level.title),
        backgroundColor: level.baseColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to Level ${level.number} tracks!",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              level.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Available Audio Exercises:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Placeholder representation for target tracks
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const Icon(Icons.audiotrack, color: Colors.grey),
                      title: Text("Audio Track #${index + 1}"),
                      subtitle: const Text("Duration: 03:45"),
                      trailing: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.blue,
                      ),
                      onTap: () {
                        // This is where you would launch the customized sub-listening screen built earlier!
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
