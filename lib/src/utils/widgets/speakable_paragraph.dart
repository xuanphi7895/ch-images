import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/tts/tts_bloc.dart';
import '../../core/tts/tts_state.dart';

class SpeakableParagraph extends StatelessWidget {
  final String text;

  const SpeakableParagraph({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TtsBloc, TtsState>(
      builder: (context, state) {
        final start = state.start;
        final end = state.end;

        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: text.substring(0, start),
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
              TextSpan(
                text: text.substring(start, end),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: text.substring(end),
                style: const TextStyle(color: Colors.black, fontSize: 18),
              ),
            ],
          ),
        );
      },
    );
  }
}
