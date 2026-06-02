import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/utils/widgets/speakable_paragraph.dart';

import '../../../core/tts/tts_bloc.dart';
import '../../../core/tts/tts_event.dart';

class ParagraphScreen extends StatelessWidget {
  const ParagraphScreen({super.key});

  final String paragraph =
      "Hello, welcome to our English learning application.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("English Learning")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SpeakableParagraph(text: paragraph),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                context.read<TtsBloc>().add(SpeakTextEvent(paragraph));
              },
              icon: const Icon(Icons.volume_up),
              label: const Text("Speak"),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                context.read<TtsBloc>().add(StopTtsEvent());
              },
              icon: const Icon(Icons.stop),
              label: const Text("Stop"),
            ),
          ],
        ),
      ),
    );
  }
}
