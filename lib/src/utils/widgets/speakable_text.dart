import 'package:flutter/material.dart';
import '../../core/services/tts_service.dart';

class SpeakableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final IconData icon;
  final Color? iconColor;
  final double iconSize;

  const SpeakableText({
    super.key,
    required this.text,
    this.style,
    this.icon = Icons.volume_up,
    this.iconColor,
    this.iconSize = 22,
  });

  Future<void> _speak() async {
    await TtsService().speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(text, style: style)),
        IconButton(
          onPressed: _speak,
          icon: Icon(icon, color: iconColor ?? Colors.blue, size: iconSize),
        ),
      ],
    );
  }
}
