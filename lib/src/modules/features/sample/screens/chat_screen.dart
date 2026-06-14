import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/chat_message.dart';
import '../services/claude_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/mic_button.dart';

class ChatScreen extends StatefulWidget {
  final String topic;
  const ChatScreen({super.key, required this.topic});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _stt = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isListening = false;
  bool _isLoading = false;
  bool _isSpeaking = false;
  bool _sttAvailable = false;
  bool _autoSpeak = true;
  String _liveTranscript = '';

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _initStt();
    _initTts();
    _startSession();
  }

  Future<void> _initStt() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      _sttAvailable = await _stt.initialize(
        onError: (e) => setState(() => _isListening = false),
        onStatus: (s) {
          if (s == 'done' || s == 'notListening') {
            setState(() => _isListening = false);
            if (_liveTranscript.isNotEmpty) {
              _sendMessage(_liveTranscript);
              _liveTranscript = '';
            }
          }
        },
      );
      setState(() {});
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => setState(() => _isSpeaking = false));
    _tts.setStartHandler(() => setState(() => _isSpeaking = true));
  }

  Future<void> _startSession() async {
    setState(() => _isLoading = true);
    try {
      final reply = await ClaudeService.sendMessage(
        messages: [{'role': 'user', 'content': 'Hello! I want to practice my English.'}],
        topic: widget.topic,
      );
      final msg = ChatMessage(text: reply, role: MessageRole.assistant);
      setState(() {
        _messages.add(msg);
        _isLoading = false;
      });
      if (_autoSpeak) _speak(reply);
      _scrollToBottom();
    } catch (e) {
      final fallback = "Hello! I'm your English tutor. Let's practice — tell me something about ${widget.topic}!";
      setState(() {
        _messages.add(ChatMessage(text: fallback, role: MessageRole.assistant));
        _isLoading = false;
      });
      if (_autoSpeak) _speak(fallback);
      _scrollToBottom();
    }
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    final cleaned = text
        .replaceAll('✅', '')
        .replaceAll('💡', '')
        .replaceAll('*', '');
    await _tts.speak(cleaned);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stt.stop();
      setState(() => _isListening = false);
      return;
    }
    if (!_sttAvailable) {
      _showSnack('Microphone not available. Please check permissions.');
      return;
    }
    await _tts.stop();
    setState(() {
      _isListening = true;
      _liveTranscript = '';
      _textController.clear();
    });
    await _stt.listen(
      onResult: (result) {
        setState(() {
          _liveTranscript = result.recognizedWords;
          _textController.text = _liveTranscript;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
    );
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    await _stt.stop();
    setState(() {
      _isListening = false;
      _liveTranscript = '';
    });

    final userMsg = ChatMessage(text: trimmed, role: MessageRole.user);
    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final apiMessages = _messages
          .where((m) => m.role != MessageRole.assistant || _messages.indexOf(m) > 0)
          .map((m) => m.toApiFormat())
          .toList();

      final reply = await ClaudeService.sendMessage(
        messages: apiMessages,
        topic: widget.topic,
      );
      final aiMsg = ChatMessage(text: reply, role: MessageRole.assistant);
      setState(() {
        _messages.add(aiMsg);
        _isLoading = false;
      });
      if (_autoSpeak) _speak(reply);
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Error: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    _stt.stop();
    _tts.stop();
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.topic, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('English Practice', style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.5))),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Icon(
                  _autoSpeak ? Icons.volume_up_outlined : Icons.volume_off_outlined,
                  size: 18,
                  color: cs.onSurface.withOpacity(0.5),
                ),
                Switch(
                  value: _autoSpeak,
                  onChanged: (v) {
                    setState(() => _autoSpeak = v);
                    if (!v) _tts.stop();
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length) {
                  return const _TypingIndicator();
                }
                return MessageBubble(message: _messages[i]);
              },
            ),
          ),
          if (_isListening)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) => Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.6 + _pulseController.value * 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _liveTranscript.isEmpty ? 'Listening... speak now' : _liveTranscript,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withOpacity(0.6),
                      fontStyle: _liveTranscript.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          _buildInputBar(cs),
        ],
      ),
    );
  }

  Widget _buildInputBar(ColorScheme cs) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withOpacity(0.4), width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          MicButton(
            isListening: _isListening,
            isAvailable: _sttAvailable,
            pulseController: _pulseController,
            onTap: _toggleListening,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 4,
                minLines: 1,
                style: TextStyle(fontSize: 15, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Type your answer...',
                  hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.4), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _SendButton(
            enabled: !_isLoading,
            onTap: () => _sendMessage(_textController.text),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final offset = ((_ctrl.value * 3 - i) % 1.0);
                  final bounce = offset < 0.5 ? offset * 2 : (1 - offset) * 2;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3 + bounce * 0.4),
                      shape: BoxShape.circle,
                    ),
                    transform: Matrix4.translationValues(0, -bounce * 4, 0),
                  );
                },
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _SendButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF185FA5) : const Color(0xFF185FA5).withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}
