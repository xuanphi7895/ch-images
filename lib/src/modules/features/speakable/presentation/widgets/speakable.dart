import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/speech_bloc.dart';
import '../bloc/speech_state.dart';

class Speakable extends StatelessWidget {
  final String text;

  const Speakable({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpeechBloc, SpeechState>(
      builder: (context, state) {
        final spans = <TextSpan>[];
        for (var i = 0; i < state.words.length; i++) {
          final isActive = state.currentIndex == i;
          spans.add(
            TextSpan(
              text: '${state.words[i]} ',
              style: TextStyle(
                backgroundColor: isActive
                    ? Colors.yellow.withOpacity(0.5)
                    : null,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }
        return RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: spans,
          ),
        );
      },
    );
  }
}
