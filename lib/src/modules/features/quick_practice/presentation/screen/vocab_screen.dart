// ════════════════════════════════════════════════════
// VOCABULARY SCREEN
// ════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/quick_practice/domain/session_result.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/vocab_bloc.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/vocab_event.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/vocab_state.dart';
import 'package:images/src/modules/features/quick_practice/presentation/screen/result_screen.dart';
import 'package:images/src/modules/features/quick_practice/presentation/widgets/practice_header.dart';
import 'package:images/src/utils/enum.dart';

class VocabScreen extends StatelessWidget {
  const VocabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VocabBloc()..add(const VocabStarted()),
      child: const _VocabView(),
    );
  }
}

class _VocabView extends StatelessWidget {
  const _VocabView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<VocabBloc, VocabState>(
        listener: (context, state) {
          if (state is VocabSessionDone) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ResultScreen(
                  result: SessionResult(
                    skill: SkillType.vocabulary,
                    xpEarned: state.xpEarned,
                    accuracyPercent: state.accuracyPercent,
                    durationSeconds: 0,
                    easyCount: state.easyCount,
                    hardCount: state.hardCount,
                    againCount: state.againCount,
                  ),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VocabLoading || state is VocabInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Purple600),
            );
          }
          if (state is VocabCardVisible) {
            return _VocabCardPage(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _VocabCardPage extends StatelessWidget {
  final VocabCardVisible state;
  const _VocabCardPage({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<VocabBloc>();
    final card = state.card;

    return Column(
      children: [
        PracticeHeader(
          title:
              'Vocabulary · Card ${state.currentIndex + 1} of ${state.totalCards}',
          progress: state.progress,
          trailing: '',
          onClose: () => Navigator.pop(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: state.isRevealed
                      ? null
                      : () => bloc.add(const VocabAnswerRevealed()),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (!state.isRevealed)
                          Text(
                            'Tap to reveal meaning',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          card.word,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.ipa,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black.withOpacity(0.45),
                          ),
                        ),
                        if (state.isRevealed) ...[
                          Divider(
                            height: 28,
                            color: Colors.black.withOpacity(0.08),
                          ),
                          Text(
                            card.meaning,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"${card.exampleSentence}"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Colors.black.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (state.isRevealed) ...[
                  const SizedBox(height: 20),
                  Text(
                    'How well did you know this?',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.45),
                      letterSpacing: .05,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _RatingButton(
                        emoji: '😅',
                        label: 'Again',
                        color: Coral600,
                        borderColor: const Color(0xFFF0997B),
                        onTap: () =>
                            bloc.add(const VocabCardRated(CardRating.again)),
                      ),
                      const SizedBox(width: 8),
                      _RatingButton(
                        emoji: '🤔',
                        label: 'Hard',
                        color: Blue600,
                        borderColor: const Color(0xFF85B7EB),
                        onTap: () =>
                            bloc.add(const VocabCardRated(CardRating.hard)),
                      ),
                      const SizedBox(width: 8),
                      _RatingButton(
                        emoji: '😊',
                        label: 'Easy',
                        color: Teal600,
                        borderColor: const Color(0xFF5DCAA5),
                        onTap: () =>
                            bloc.add(const VocabCardRated(CardRating.easy)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📅 Review again in: ${card.reviewIntervalDays} day(s)',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'SRS info',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Purple600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _RatingButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Design tokens ─────────────────────────────────
const Purple900 = Color(0xFF26215C);
const Purple800 = Color(0xFF3C3489);
const Purple600 = Color(0xFF534AB7);
const Purple200 = Color(0xFFAFA9EC);
const Purple50 = Color(0xFFEEEDFE);
const Teal600 = Color(0xFF0F6E56);
const Teal50 = Color(0xFFE1F5EE);
const Blue600 = Color(0xFF185FA5);
const Blue200 = Color(0xFFB5D4F4);
const Blue50 = Color(0xFFE6F1FB);
const Coral600 = Color(0xFF993C1D);
const Coral50 = Color(0xFFFAECE7);
const Amber400 = Color(0xFFEF9F27);
