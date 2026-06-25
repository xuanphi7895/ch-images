// speaking_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/speaking/presentation/bloc/speaking_event.dart';
import 'package:images/src/modules/features/speaking/presentation/bloc/speaking_state.dart';
import 'package:images/src/modules/features/speaking/presentation/bloc/speaking_bloc.dart';
import 'package:images/src/modules/features/speaking/data/speaking_models.dart';

// ─── Design tokens ────────────────────────────────────
const _purple800 = Color(0xFF3C3489);
const _purple600 = Color(0xFF534AB7);
const _purple200 = Color(0xFFAFA9EC);
const _purple50 = Color(0xFFEEEDFE);
const _teal600 = Color(0xFF0F6E56);
const _teal50 = Color(0xFFE1F5EE);
const _coral600 = Color(0xFF993C1D);
const _coral50 = Color(0xFFFAECE7);
const _blue600 = Color(0xFF185FA5);
const _blue50 = Color(0xFFE6F1FB);
const _amber400 = Color(0xFFEF9F27);
const _amber50 = Color(0xFFFAEEDA);
const _green600 = Color(0xFF3B6D11);
const _green50 = Color(0xFFEAF3DE);
const _gray50 = Color(0xFFF1EFE8);

// ─────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────

class SpeakingScreen extends StatelessWidget {
  const SpeakingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SpeakingBloc()..add(const SpeakingScreenLoaded()),
      child: const _SpeakingView(),
    );
  }
}

// ─────────────────────────────────────────────────────
// ROOT VIEW
// ─────────────────────────────────────────────────────

class _SpeakingView extends StatelessWidget {
  const _SpeakingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<SpeakingBloc, SpeakingState>(
        builder: (context, state) {
          if (state is SpeakingInitial) {
            return const Center(
              child: CircularProgressIndicator(color: _purple600),
            );
          }
          if (state is SpeakingScenarioPicker) {
            return _ScenarioPickerView(state: state);
          }
          if (state is SpeakingConversation) {
            return _ConversationView(state: state);
          }
          if (state is SpeakingDone) {
            return _ResultsView(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
// SCENARIO PICKER
// ═════════════════════════════════════════════════════

class _ScenarioPickerView extends StatelessWidget {
  final SpeakingScenarioPicker state;
  const _ScenarioPickerView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SimpleHeader(
          title: 'Speaking practice',
          subtitle: 'Choose a scenario',
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: state.scenarios.length,
            itemBuilder: (_, i) => _ScenarioCard(scenario: state.scenarios[i]),
          ),
        ),
      ],
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final SpeakingScenarioData scenario;
  const _ScenarioCard({required this.scenario});

  IconData get _icon {
    switch (scenario.scenario) {
      case SpeakingScenario.jobInterview:
        return Icons.work_outline;
      case SpeakingScenario.airportCheckin:
        return Icons.flight_outlined;
      case SpeakingScenario.restaurantOrder:
        return Icons.restaurant_outlined;
      case SpeakingScenario.hotelBooking:
        return Icons.hotel_outlined;
      case SpeakingScenario.doctorVisit:
        return Icons.local_hospital_outlined;
      case SpeakingScenario.casualConversation:
        return Icons.chat_outlined;
    }
  }

  Color get _diffColor {
    switch (scenario.difficulty) {
      case SpeakingDifficulty.beginner:
        return _teal600;
      case SpeakingDifficulty.intermediate:
        return _amber400;
      case SpeakingDifficulty.advanced:
        return _coral600;
    }
  }

  Color get _diffBg {
    switch (scenario.difficulty) {
      case SpeakingDifficulty.beginner:
        return _teal50;
      case SpeakingDifficulty.intermediate:
        return _amber50;
      case SpeakingDifficulty.advanced:
        return _coral50;
    }
  }

  String get _diffLabel {
    switch (scenario.difficulty) {
      case SpeakingDifficulty.beginner:
        return 'Beginner';
      case SpeakingDifficulty.intermediate:
        return 'Intermediate';
      case SpeakingDifficulty.advanced:
        return 'Advanced';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.read<SpeakingBloc>().add(SpeakingScenarioSelected(scenario)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.09), width: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _purple50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _purple600, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          scenario.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _Pill(label: _diffLabel, color: _diffColor, bg: _diffBg),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scenario.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.black.withOpacity(0.35),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${scenario.estimatedMinutes} min',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.bolt_outlined,
                        size: 12,
                        color: Colors.black.withOpacity(0.35),
                      ),
                      Text(
                        '+${scenario.xpReward} XP',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.black.withOpacity(0.25),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
// CONVERSATION VIEW
// ═════════════════════════════════════════════════════

class _ConversationView extends StatefulWidget {
  final SpeakingConversation state;
  const _ConversationView({required this.state});

  @override
  State<_ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<_ConversationView> {
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(_ConversationView old) {
    super.didUpdateWidget(old);
    if (widget.state.turns.length != old.state.turns.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;

    return Column(
      children: [
        // Header
        _ConversationHeader(scenario: s.scenario),

        // Error banner
        if (s.errorMessage != null) _ErrorBanner(message: s.errorMessage!),

        // Hint banner
        if (s.hint != null) _HintBanner(hint: s.hint!),

        // Target phrases
        _TargetPhrasesRow(phrases: s.scenario.targetPhrases),

        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            itemCount: s.turns.length + (s.liveTranscript.isNotEmpty ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == s.turns.length && s.liveTranscript.isNotEmpty) {
                return _LiveTranscriptBubble(text: s.liveTranscript);
              }
              return _TurnBubble(
                turn: s.turns[i],
                isExpanded: s.expandedFeedbackTurnId == s.turns[i].id,
              );
            },
          ),
        ),

        // Bottom controls
        _BottomControls(status: s.status, turnCount: s.userTurnCount),

        SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// CONVERSATION HEADER
// ─────────────────────────────────────────────────────

class _ConversationHeader extends StatelessWidget {
  final SpeakingScenarioData scenario;
  const _ConversationHeader({required this.scenario});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _purple800,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 14,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                context.read<SpeakingBloc>().add(const SpeakingRestarted()),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: _purple200,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // AI avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.aiRole,
                  style: const TextStyle(
                    color: Color(0xFFEEEDFE),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  scenario.title,
                  style: const TextStyle(color: _purple200, fontSize: 12),
                ),
              ],
            ),
          ),

          // End session
          GestureDetector(
            onTap: () =>
                context.read<SpeakingBloc>().add(const SpeakingSessionEnded()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text(
                'End session',
                style: TextStyle(color: _purple200, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// TARGET PHRASES ROW
// ─────────────────────────────────────────────────────

class _TargetPhrasesRow extends StatelessWidget {
  final List<String> phrases;
  const _TargetPhrasesRow({required this.phrases});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: Colors.black.withOpacity(0.03),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: phrases.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: _purple600.withOpacity(0.25), width: 0.5),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '"${phrases[i]}"',
            style: const TextStyle(
              fontSize: 11,
              color: _purple600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// TURN BUBBLE
// ─────────────────────────────────────────────────────

class _TurnBubble extends StatelessWidget {
  final SpeakingTurn turn;
  final bool isExpanded;

  const _TurnBubble({required this.turn, required this.isExpanded});

  bool get _isUser => turn.role == TurnRole.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: _isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: _isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!_isUser) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: _purple50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy_outlined,
                    color: _purple600,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _isUser ? _purple600 : _gray50,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(_isUser ? 14 : 4),
                      bottomRight: Radius.circular(_isUser ? 4 : 14),
                    ),
                  ),
                  child: Text(
                    turn.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: _isUser ? Colors.white : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              if (_isUser) const SizedBox(width: 8),
            ],
          ),

          // Feedback toggle (user turns only)
          if (_isUser && turn.feedback != null) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => context.read<SpeakingBloc>().add(
                SpeakingFeedbackToggled(turn.id),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _purple50,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${turn.feedback!.overallScore}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _purple600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: _purple600,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Expanded feedback panel
            if (isExpanded) _FeedbackPanel(feedback: turn.feedback!),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// FEEDBACK PANEL
// ─────────────────────────────────────────────────────

class _FeedbackPanel extends StatelessWidget {
  final SpeakingFeedback feedback;
  const _FeedbackPanel({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _purple50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _purple600.withOpacity(0.15), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score bars
          _ScoreBar('Pronunciation', feedback.pronunciationScore, _blue600),
          const SizedBox(height: 6),
          _ScoreBar('Grammar', feedback.grammarScore, _teal600),
          const SizedBox(height: 6),
          _ScoreBar('Vocabulary', feedback.vocabularyScore, _green600),
          const SizedBox(height: 6),
          _ScoreBar('Fluency', feedback.fluencyScore, _amber400),

          if (feedback.correctedText.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Corrected version:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _purple600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              feedback.correctedText,
              style: const TextStyle(
                fontSize: 13,
                color: _purple600,
                height: 1.5,
              ),
            ),
          ],

          if (feedback.nativeSuggestion.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Native speaker version:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _teal600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              feedback.nativeSuggestion,
              style: const TextStyle(
                fontSize: 13,
                color: _teal600,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],

          // Issue items
          if (feedback.items.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...feedback.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 14, color: _coral600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 12, height: 1.5),
                          children: [
                            TextSpan(
                              text: '${item.issue} — ',
                              style: const TextStyle(color: _coral600),
                            ),
                            TextSpan(
                              text: item.suggestion,
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  const _ScoreBar(this.label, this.score, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black.withOpacity(0.55),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 5,
              backgroundColor: Colors.black.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '$score',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// LIVE TRANSCRIPT BUBBLE
// ─────────────────────────────────────────────────────

class _LiveTranscriptBubble extends StatelessWidget {
  final String text;
  const _LiveTranscriptBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _purple600.withOpacity(0.4),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// BOTTOM CONTROLS
// ─────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final SpeakingStatus status;
  final int turnCount;

  const _BottomControls({required this.status, required this.turnCount});

  String get _statusLabel {
    switch (status) {
      case SpeakingStatus.idle:
        return 'Hold mic to speak';
      case SpeakingStatus.recording:
        return 'Listening… release to send';
      case SpeakingStatus.processing:
        return 'AI is thinking…';
      case SpeakingStatus.aiSpeaking:
        return 'AI is speaking…';
    }
  }

  Color get _statusColor {
    switch (status) {
      case SpeakingStatus.idle:
        return Colors.black38;
      case SpeakingStatus.recording:
        return _coral600;
      case SpeakingStatus.processing:
        return _purple600;
      case SpeakingStatus.aiSpeaking:
        return _teal600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = status == SpeakingStatus.recording;
    final isProcessing = status == SpeakingStatus.processing;
    final isAiSpeaking = status == SpeakingStatus.aiSpeaking;
    final canInteract = status == SpeakingStatus.idle || isRecording;

    return Column(
      children: [
        // Status label
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _statusLabel,
              key: ValueKey(status),
              style: TextStyle(
                fontSize: 12,
                color: _statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Controls row
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hint button
              _ControlButton(
                icon: Icons.lightbulb_outline,
                label: 'Hint',
                color: _amber400,
                bg: _amber50,
                enabled: status == SpeakingStatus.idle,
                onTap: () => context.read<SpeakingBloc>().add(
                  const SpeakingHintRequested(),
                ),
              ),

              // Mic button — center
              GestureDetector(
                onTapDown: canInteract
                    ? (_) => context.read<SpeakingBloc>().add(
                        const SpeakingMicPressed(),
                      )
                    : null,
                onTapUp: isRecording
                    ? (_) => context.read<SpeakingBloc>().add(
                        const SpeakingMicReleased(),
                      )
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isProcessing || isAiSpeaking
                        ? Colors.black.withOpacity(0.07)
                        : isRecording
                        ? _coral600
                        : _purple600,
                    boxShadow: isRecording
                        ? [
                            BoxShadow(
                              color: _coral600.withOpacity(0.4),
                              blurRadius: 18,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: isProcessing
                      ? const Padding(
                          padding: EdgeInsets.all(22),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isRecording
                              ? Icons.stop_rounded
                              : isAiSpeaking
                              ? Icons.volume_up_outlined
                              : Icons.mic_none_outlined,
                          color: isProcessing || isAiSpeaking
                              ? Colors.black26
                              : Colors.white,
                          size: 30,
                        ),
                ),
              ),

              // End session button
              _ControlButton(
                icon: Icons.flag_outlined,
                label: 'Finish',
                color: _teal600,
                bg: _teal50,
                enabled: turnCount > 0,
                onTap: () => context.read<SpeakingBloc>().add(
                  const SpeakingSessionEnded(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final bool enabled;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
// RESULTS VIEW
// ═════════════════════════════════════════════════════

class _ResultsView extends StatelessWidget {
  final SpeakingDone state;
  const _ResultsView({required this.state});

  String get _grade {
    final s = state.result.overallScore;
    if (s >= 85) return 'Excellent!';
    if (s >= 70) return 'Good job!';
    if (s >= 55) return 'Keep practising';
    return 'Try again';
  }

  String get _duration {
    final m = state.result.durationSeconds ~/ 60;
    final s = state.result.durationSeconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final r = state.result;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 32,
              left: 20,
              right: 20,
            ),
            color: _purple800,
            child: Column(
              children: [
                const Text('🗣️', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 10),
                Text(
                  _grade,
                  style: const TextStyle(
                    color: Color(0xFFEEEDFE),
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.scenario.title,
                  style: const TextStyle(color: _purple200, fontSize: 13),
                ),
                const SizedBox(height: 16),
                // Overall score circle
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${r.overallScore}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        '%',
                        style: TextStyle(color: _purple200, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Mini stat row
                  Row(
                    children: [
                      _MiniStat(
                        label: 'Turns',
                        value: '${r.totalTurns}',
                        color: _purple600,
                        bg: _purple50,
                      ),
                      const SizedBox(width: 10),
                      _MiniStat(
                        label: 'XP',
                        value: '+${r.xpEarned}',
                        color: _amber400,
                        bg: _amber50,
                      ),
                      const SizedBox(width: 10),
                      _MiniStat(
                        label: 'Time',
                        value: _duration,
                        color: _blue600,
                        bg: _blue50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Skill breakdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black.withOpacity(0.09),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Skill breakdown',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _ScoreBar(
                          'Pronunciation',
                          r.avgPronunciation,
                          _blue600,
                        ),
                        const SizedBox(height: 8),
                        _ScoreBar('Grammar', r.avgGrammar, _teal600),
                        const SizedBox(height: 8),
                        _ScoreBar('Vocabulary', r.avgVocabulary, _green600),
                        const SizedBox(height: 8),
                        _ScoreBar('Fluency', r.avgFluency, _amber400),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CTAs
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Try again',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () => context.read<SpeakingBloc>().add(
                        const SpeakingRestarted(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Colors.black.withOpacity(0.15),
                          width: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.popUntil(context, (r) => r.isFirst),
                      child: const Text(
                        'Back to home',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════
// SHARED WIDGETS
// ═════════════════════════════════════════════════════

class _SimpleHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SimpleHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _purple800,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: _purple200,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFEEEDFE),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: _purple200, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _Pill({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  final String hint;
  const _HintBanner({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _amber50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _amber400.withOpacity(0.4), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: _amber400, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hint,
              style: const TextStyle(fontSize: 13, color: Color(0xFF854F0B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

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
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
