enum MessageRole { user, assistant }

class ChatMessage {
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, String> toApiFormat() {
    return {
      'role': role == MessageRole.user ? 'user' : 'assistant',
      'content': text,
    };
  }
}
