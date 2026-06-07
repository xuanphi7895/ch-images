import 'package:flutter/material.dart';
import 'package:images/src/modules/features/ai_tutor/presentation/bloc/ai_tutor_state.dart';
import 'package:images/src/utils/color.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final String tutorAvatarUrl;
  final bool isPlayingTTS;
  final VoidCallback onPlayTTS;
  final VoidCallback onTranslate;

  const ChatBubble({
    super.key,
    required this.message,
    required this.tutorAvatarUrl,
    required this.isPlayingTTS,
    required this.onPlayTTS,
    required this.onTranslate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.sender == 'user';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            ClipOval(
              child: Image.network(
                tutorAvatarUrl,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 36,
                  height: 36,
                  color: CustomColors.Purple50,
                  child: const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: CustomColors.Purple600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Chat Bubble Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? CustomColors.Purple600
                        : Colors.grey.withOpacity(0.08),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 15,
                          color: isUser ? Colors.white : const Color(0xFF2A3C44),
                          height: 1.4,
                        ),
                      ),
                      // If translation toggled
                      if (message.showTranslation) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: isUser
                                    ? Colors.white24
                                    : Colors.black.withOpacity(0.08),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.g_translate_outlined,
                                size: 12,
                                color: isUser ? Colors.white70 : Colors.black45,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  message.translation,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isUser
                                        ? Colors.white.withOpacity(0.85)
                                        : Colors.black54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Audio & Translation Controls (For Tutor Messages)
                if (!isUser) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        icon: Icon(
                          isPlayingTTS ? Icons.volume_up : Icons.volume_up_outlined,
                          size: 16,
                          color: isPlayingTTS ? CustomColors.Purple600 : Colors.black45,
                        ),
                        onPressed: onPlayTTS,
                      ),
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        icon: Icon(
                          message.showTranslation
                              ? Icons.translate
                              : Icons.translate_outlined,
                          size: 16,
                          color: message.showTranslation
                              ? CustomColors.Purple600
                              : Colors.black45,
                        ),
                        onPressed: onTranslate,
                      ),
                    ],
                  ),
                ],
                // Grammar Correction Card (For User Messages)
                if (isUser && message.correction != null) ...[
                  const SizedBox(height: 8),
                  _buildCorrectionCard(context, message.correction!),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 18,
              backgroundColor: CustomColors.Purple50,
              child: Icon(
                Icons.person,
                size: 20,
                color: CustomColors.Purple600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCorrectionCard(BuildContext context, GrammarCorrection correction) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAECE7), // soft Coral50 warning background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAAFA2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: Color(0xFF993C1D), size: 16),
              SizedBox(width: 6),
              Text(
                'Instant Feedback',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF993C1D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                const TextSpan(text: 'Instead of: '),
                TextSpan(
                  text: '"${correction.original}"',
                  style: const TextStyle(
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                const TextSpan(text: 'Try saying: '),
                TextSpan(
                  text: '"${correction.corrected}"',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            correction.explanation,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
