import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF185FA5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF185FA5) : cs.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
              ),
              child: isUser
                  ? Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    )
                  : _buildAIMessage(context, message.text, cs),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_outline, color: cs.onSurface.withOpacity(0.6), size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAIMessage(BuildContext context, String text, ColorScheme cs) {
    final parts = _parseFeedback(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) {
        if (part['type'] == 'good') {
          return Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✅ ', style: TextStyle(fontSize: 13)),
                Flexible(
                  child: Text(
                    part['text']!.trim(),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF3B6D11), height: 1.4),
                  ),
                ),
              ],
            ),
          );
        } else if (part['type'] == 'tip') {
          return Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFAEEDA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 13)),
                Flexible(
                  child: Text(
                    part['text']!.trim(),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF854F0B), height: 1.4),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Text(
            part['text']!,
            style: TextStyle(fontSize: 15, color: cs.onSurface, height: 1.5),
          );
        }
      }).toList(),
    );
  }

  List<Map<String, String>> _parseFeedback(String text) {
    final List<Map<String, String>> parts = [];
    final lines = text.split('\n');
    final StringBuffer buffer = StringBuffer();

    for (final line in lines) {
      if (line.contains('✅')) {
        if (buffer.isNotEmpty) {
          parts.add({'type': 'text', 'text': buffer.toString().trim()});
          buffer.clear();
        }
        parts.add({'type': 'good', 'text': line.replaceAll('✅', '').trim()});
      } else if (line.contains('💡')) {
        if (buffer.isNotEmpty) {
          parts.add({'type': 'text', 'text': buffer.toString().trim()});
          buffer.clear();
        }
        parts.add({'type': 'tip', 'text': line.replaceAll('💡', '').trim()});
      } else {
        if (buffer.isNotEmpty) buffer.write('\n');
        buffer.write(line);
      }
    }
    if (buffer.isNotEmpty) {
      parts.add({'type': 'text', 'text': buffer.toString().trim()});
    }
    return parts.where((p) => p['text']!.isNotEmpty).toList();
  }
}
