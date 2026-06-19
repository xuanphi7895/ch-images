// gemini_live_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'gemini_live_bloc.dart';

// ─── Design tokens ────────────────────────────────────
const _purple800 = Color(0xFF3C3489);
const _purple600 = Color(0xFF534AB7);
const _purple200 = Color(0xFFAFA9EC);
const _purple50 = Color(0xFFEEEDFE);
const _teal600 = Color(0xFF0F6E56);
const _teal50 = Color(0xFFE1F5EE);
const _coral600 = Color(0xFF993C1D);
const _coral50 = Color(0xFFFAECE7);
const _gray50 = Color(0xFFF1EFE8);

// ─────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────

class GeminiLiveScreen extends StatelessWidget {
  const GeminiLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GeminiLiveBloc()..add(const LiveStarted()),
      child: const _LiveView(),
    );
  }
}

// ─────────────────────────────────────────────────────
// VIEW
// ─────────────────────────────────────────────────────

class _LiveView extends StatelessWidget {
  const _LiveView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<GeminiLiveBloc, LiveState>(
        builder: (context, state) {
          // Show loading only on very first load (LiveInitial)
          if (state is LiveInitial) {
            return const Center(
              child: CircularProgressIndicator(color: _purple600),
            );
          }
          if (state is LiveReady) return _ReadyBody(state: state);
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────

class _ReadyBody extends StatefulWidget {
  final LiveReady state;
  const _ReadyBody({required this.state});

  @override
  State<_ReadyBody> createState() => _ReadyBodyState();
}

class _ReadyBodyState extends State<_ReadyBody> {
  final _scroll = ScrollController();
  final _textCtrl = TextEditingController();

  @override
  void didUpdateWidget(_ReadyBody old) {
    super.didUpdateWidget(old);
    // Auto-scroll to bottom when new message arrives
    if (widget.state.messages.length != old.state.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _sendText() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<GeminiLiveBloc>().add(LiveTextSent(text));
    _textCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return WillPopScope(
      onWillPop: () async {
        context.read<GeminiLiveBloc>().add(const LiveStopped());
        return true;
      },
      child: Column(
        children: [
          // ── Purple header ──
          _Header(status: s.status),

          // ── Connecting spinner bar ──
          if (s.status == LiveStatus.connecting) _ConnectingBanner(),

          // ── Error banner ──
          if (s.errorMessage != null)
            _ErrorBanner(
              message: s.errorMessage!,
              onRetry: () =>
                  context.read<GeminiLiveBloc>().add(const LiveStarted()),
            ),

          // ── Chat messages ──
          Expanded(
            child: s.messages.isEmpty
                ? _EmptyHint(status: s.status)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    itemCount: s.messages.length,
                    itemBuilder: (_, i) => _MessageBubble(msg: s.messages[i]),
                  ),
          ),

          // ── Status label ──
          _StatusLabel(status: s.status),

          // ── Mic button — ALWAYS visible ──
          _MicButton(status: s.status),

          const SizedBox(height: 12),

          // ── Text input — always visible ──
          _TextInputRow(
            controller: _textCtrl,
            enabled:
                s.status == LiveStatus.idle || s.status == LiveStatus.listening,
            onSend: _sendText,
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final LiveStatus status;
  const _Header({required this.status});

  Color get _dotColor {
    switch (status) {
      case LiveStatus.disconnected:
        return Colors.red.shade300;
      case LiveStatus.connecting:
        return Colors.orange;
      case LiveStatus.idle:
      case LiveStatus.listening:
      case LiveStatus.aiSpeaking:
        return const Color(0xFF5DCAA5);
    }
  }

  String get _dotLabel {
    switch (status) {
      case LiveStatus.disconnected:
        return 'Disconnected';
      case LiveStatus.connecting:
        return 'Connecting…';
      case LiveStatus.idle:
        return 'Connected';
      case LiveStatus.listening:
        return 'Listening';
      case LiveStatus.aiSpeaking:
        return 'AI speaking';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      color: _purple800,
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              context.read<GeminiLiveBloc>().add(const LiveStopped());
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: _purple200,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gemini Live',
                  style: TextStyle(
                    color: Color(0xFFEEEDFE),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Real-time voice conversation',
                  style: TextStyle(color: _purple200, fontSize: 12),
                ),
              ],
            ),
          ),

          // Connection status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  _dotLabel,
                  style: const TextStyle(color: _purple200, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Reconnect button
          GestureDetector(
            onTap: () =>
                context.read<GeminiLiveBloc>().add(const LiveStarted()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Icon(Icons.refresh, color: _purple200, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// CONNECTING BANNER
// ─────────────────────────────────────────────────────

class _ConnectingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFFFFF3CD),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 13,
            height: 13,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFD4900B),
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Connecting to Gemini Live…',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFD4900B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// EMPTY HINT (centre of chat area when no messages)
// ─────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final LiveStatus status;
  const _EmptyHint({required this.status});

  @override
  Widget build(BuildContext context) {
    final isConnecting = status == LiveStatus.connecting;
    final isDisconnected = status == LiveStatus.disconnected;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _purple50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: _purple600,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isConnecting
                ? 'Setting up connection…'
                : isDisconnected
                ? 'Not connected'
                : 'Tap the mic and start speaking!',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isDisconnected
                ? 'Tap the refresh icon to reconnect'
                : 'Gemini will reply with voice in real-time',
            style: const TextStyle(fontSize: 12, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// MESSAGE BUBBLE
// ─────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final LiveMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _AiAvatar(isStreaming: msg.isStreaming),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? _purple600 : _gray50,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isUser ? 14 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUser ? Colors.white : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (msg.isStreaming) ...[
                    const SizedBox(width: 4),
                    _BlinkingCursor(
                      color: isUser ? Colors.white70 : Colors.black38,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _AiAvatar extends StatelessWidget {
  final bool isStreaming;
  const _AiAvatar({required this.isStreaming});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isStreaming ? _teal50 : _purple50,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isStreaming ? Icons.volume_up_outlined : Icons.smart_toy_outlined,
        color: isStreaming ? _teal600 : _purple600,
        size: 15,
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final Color color;
  const _BlinkingCursor({required this.color});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(width: 2, height: 14, color: widget.color),
    );
  }
}

// ─────────────────────────────────────────────────────
// STATUS LABEL
// ─────────────────────────────────────────────────────

class _StatusLabel extends StatelessWidget {
  final LiveStatus status;
  const _StatusLabel({required this.status});

  String get _label {
    switch (status) {
      case LiveStatus.disconnected:
        return 'Not connected — tap 🔄 to reconnect';
      case LiveStatus.connecting:
        return 'Connecting…';
      case LiveStatus.idle:
        return 'Tap mic to speak';
      case LiveStatus.listening:
        return 'Listening… tap again to stop';
      case LiveStatus.aiSpeaking:
        return 'Gemini is speaking…';
    }
  }

  Color get _color {
    switch (status) {
      case LiveStatus.disconnected:
        return Colors.red.shade300;
      case LiveStatus.connecting:
        return const Color(0xFFD4900B);
      case LiveStatus.idle:
        return Colors.black38;
      case LiveStatus.listening:
        return _coral600;
      case LiveStatus.aiSpeaking:
        return _teal600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          _label,
          key: ValueKey(status),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: _color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// MIC BUTTON  — ALWAYS VISIBLE
// ─────────────────────────────────────────────────────

class _MicButton extends StatelessWidget {
  final LiveStatus status;
  const _MicButton({required this.status});

  bool get _isListening => status == LiveStatus.listening;
  bool get _isAiSpeaking => status == LiveStatus.aiSpeaking;
  bool get _isConnecting => status == LiveStatus.connecting;

  // Mic is tappable when idle or listening
  bool get _isTappable =>
      status == LiveStatus.idle || status == LiveStatus.listening;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isTappable
          ? () => context.read<GeminiLiveBloc>().add(const LiveMicToggled())
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Always has a visible colour — never transparent
          color: _isListening
              ? _coral600
              : _isAiSpeaking
              ? _teal600
              : _isConnecting
              ? Colors.grey.shade300
              : _purple600,
          boxShadow: _isListening
              ? [
                  BoxShadow(
                    color: _coral600.withOpacity(0.45),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                ]
              : null,
        ),
        child: _isConnecting
            ? const Padding(
                padding: EdgeInsets.all(22),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Icon(
                _isListening
                    ? Icons.stop_rounded
                    : _isAiSpeaking
                    ? Icons.volume_up_outlined
                    : Icons.mic_none_outlined,
                color: Colors.white,
                size: 30,
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// TEXT INPUT ROW
// ─────────────────────────────────────────────────────

class _TextInputRow extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  const _TextInputRow({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: enabled
                    ? 'Or type a message…'
                    : 'Connect first to type…',
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.30),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.04),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedOpacity(
            opacity: enabled ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: enabled ? onSend : null,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _purple600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// ERROR BANNER
// ─────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _coral50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _coral600.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _coral600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: _coral600),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _coral600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
