import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/voice_interview/presentation/bloc/voiceI_iterview_event.dart';
import 'package:images/src/modules/features/voice_interview/presentation/bloc/voice_interview_bloc.dart';
import 'package:images/src/modules/features/voice_interview/presentation/bloc/voice_interview_state.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceInterviewPage extends StatefulWidget {
  const VoiceInterviewPage({super.key});

  @override
  State<VoiceInterviewPage> createState() => _VoiceInterviewPageState();
}

class _VoiceInterviewPageState extends State<VoiceInterviewPage> {
  final SpeechToText _speech = SpeechToText();

  String _transcript = '';

  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize();
  }

  Future<void> _startListening() async {
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcript = result.recognizedWords;
        });
      },
    );

    setState(() {
      _isListening = true;
    });
  }

  Future<void> _stopListening() async {
    await _speech.stop();

    setState(() {
      _isListening = false;
    });

    if (_transcript.isNotEmpty) {
      // context.read<VoiceInterviewBloc>().add(SendAnswerEvent(_transcript));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Interview')),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<VoiceInterviewBloc, VoiceInterviewState>(
              builder: (context, state) {
                return ListView(
                  children: [
                    // Text(state.currentQuestion),
                    const SizedBox(height: 16),

                    Text("You: $_transcript"),

                    const SizedBox(height: 16),

                    // Text(state.aiResponse),
                  ],
                );
              },
            ),
          ),

          Text(_isListening ? '🎤 Listening...' : 'Stopped'),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startListening,
                child: const Text('Start'),
              ),

              const SizedBox(width: 16),

              ElevatedButton(
                onPressed: _stopListening,
                child: const Text('Stop'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
