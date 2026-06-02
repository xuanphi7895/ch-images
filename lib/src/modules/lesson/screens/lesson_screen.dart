import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:images/src/modules/quiz/screens/quiz_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:images/src/modules/features/speakable/presentation/bloc/speech_bloc.dart';
import 'package:images/src/modules/features/speakable/presentation/bloc/speech_state.dart';
import 'package:images/src/modules/features/speakable/presentation/widgets/speakable.dart';
// import 'package:images/src/utils/widgets/speakable_paragraph.dart';
import 'package:images/src/utils/widgets/speakable_text.dart';

// class LessonScreen extends StatelessWidget {
//   const LessonScreen({super.key, required this.topicId, required this.title});
//   final String topicId;
//   final String title;

//   Future<void> speak(String text) async {
//     final _tts = FlutterTts();
//     await _tts.stop();
//     await _tts.speak(text);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(title)),
//       body: ListView(
//         padding: const EdgeInsets.all(20),
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: Container(
//               height: 140,
//               color: Theme.of(context).colorScheme.primaryContainer,
//               child: Icon(
//                 Icons.play_circle_fill,
//                 size: 64,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Present simple',
//             style: Theme.of(
//               context,
//             ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'We use the present simple for habits and facts.\n\n'
//             '• I work every day.\n'
//             '• She speaks English.',
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
//           ),
//           const SizedBox(height: 32),

//           // FilledButton.icon(
//           //   onPressed: () => Navigator.push(
//           //     context,
//           //     MaterialPageRoute(builder: (_) => QuizScreen(topicId: topicId)),
//           //   ),
//           //   icon: const Icon(Icons.quiz),
//           //   label: const Text('Start quiz'),
//           // ),
//           // IconButton(
//           //   icon: const Icon(Icons.volume_up),
//           //   // onPressed: () => {},
//           //   onPressed: () => speak('Hello, how are you? I fine, thank you.'),
//           // ),
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: SpeakableText(text: "Good morning"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.topicId,
    required this.title,
    required this.text,
  });
  final String text;
  final String topicId;
  final String title;

  @override
  State<LessonScreen> createState() => _LessonTtsWidgetState();
}

class _LessonTtsWidgetState extends State<LessonScreen> {
  final FlutterTts _tts = FlutterTts();

  late List<String> _words;
  int? _currentIndex;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');

    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45);

    _tts.setProgressHandler((text, start, end, spokenWord) {
      final normalizedSpoken = _normalize(spokenWord);
      final idx = _words.indexWhere((w) => _normalize(w) == normalizedSpoken);
      if (!mounted) return;
      setState(() => _currentIndex = idx == -1 ? null : idx);
    });

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _currentIndex = null;
      });
    });
  }

  String _normalize(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  Future<void> _speak() async {
    await _tts.stop();
    setState(() {
      _isPlaying = true;
      _currentIndex = null;
    });
    await _tts.speak(widget.text);
  }

  Future<void> _stop() async {
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _currentIndex = null;
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       RichText(
  //         text: TextSpan(
  //           style: DefaultTextStyle.of(context).style.copyWith(fontSize: 18),
  //           children: [
  //             for (var i = 0; i < _words.length; i++)
  //               TextSpan(
  //                 text: '${_words[i]} ',
  //                 style: TextStyle(
  //                   fontWeight: _currentIndex == i
  //                       ? FontWeight.bold
  //                       : FontWeight.normal,
  //                   backgroundColor: _currentIndex == i
  //                       ? Colors.yellow.withOpacity(0.45)
  //                       : null,
  //                 ),
  //               ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       Row(
  //         children: [
  //           FilledButton.icon(
  //             onPressed: _isPlaying ? null : _speak,
  //             icon: const Icon(Icons.volume_up),
  //             label: const Text('Listen'),
  //           ),
  //           const SizedBox(width: 8),
  //           OutlinedButton.icon(
  //             onPressed: _isPlaying ? _stop : null,
  //             icon: const Icon(Icons.stop),
  //             label: const Text('Stop'),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sparkle English - ${widget.title}')),
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

          // FilledButton.icon(
          //   onPressed: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (_) => QuizScreen(topicId: topicId)),
          //   ),
          //   icon: const Icon(Icons.quiz),
          //   label: const Text('Start quiz'),
          // ),
          // IconButton(
          //   icon: const Icon(Icons.volume_up),
          //   // onPressed: () => {},
          //   onPressed: () => speak('Hello, how are you? I fine, thank you.'),
          // ),
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(fontSize: 18),
              children: [
                for (var i = 0; i < _words.length; i++)
                  TextSpan(
                    text: '${_words[i]} ',
                    style: TextStyle(
                      fontWeight: _currentIndex == i
                          ? FontWeight.bold
                          : FontWeight.normal,
                      backgroundColor: _currentIndex == i
                          ? Colors.blue.withOpacity(0.45)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _isPlaying ? null : _speak,
                icon: const Icon(Icons.volume_up),
                label: const Text('Listen'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _isPlaying ? _stop : null,
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SpeakableText(text: "Good morning"),
            ),
          ),
        ],
      ),
    );
  }
}
