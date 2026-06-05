// ════════════════════════════════════════════════════
// GRAMMAR SCREEN
// ════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/quick_practice/domain/session_result.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/grammar_bloc.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/grammar_event.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/grammar_state.dart';
import 'package:images/src/modules/features/quick_practice/presentation/screen/result_screen.dart';
import 'package:images/src/modules/features/quick_practice/presentation/widgets/practice_header.dart';
import 'package:images/src/utils/enum.dart';

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GrammarBloc()..add(const GrammarStarted()),
      child: const _GrammarView(),
    );
  }
}

class _GrammarView extends StatelessWidget {
  const _GrammarView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<GrammarBloc, GrammarState>(
        listener: (context, state) {
          if (state is GrammarSessionDone) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ResultScreen(
                  result: SessionResult(
                    skill: SkillType.grammar,
                    xpEarned: state.xpEarned,
                    accuracyPercent: state.accuracyPercent,
                    durationSeconds: state.durationSeconds,
                    easyCount: state.correctCount,
                    hardCount: 0,
                    againCount: state.totalQuestions - state.correctCount,
                  ),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GrammarLoading || state is GrammarInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Purple600),
            );
          }
          if (state is GrammarQuestionVisible) {
            return _GrammarQuestionPage(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _GrammarQuestionPage extends StatelessWidget {
  final GrammarQuestionVisible state;
  const _GrammarQuestionPage({required this.state});

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<GrammarBloc>();
    final q = state.question;

    return Column(
      children: [
        PracticeHeader(
          title:
              'Grammar · Question ${state.currentIndex + 1} of ${state.totalQuestions}',
          progress: state.progress,
          trailing: '⏱ ${_formatTime(state.elapsedSeconds)}',
          onClose: () => Navigator.pop(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.black.withOpacity(0.1),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.45),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SentenceWithBlank(
                        sentence: q.sentence,
                        blankWord: q.blankWord,
                        isAnswered: state.isAnswered,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Choose the correct form',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.45),
                    letterSpacing: .05,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(q.options.length, (i) {
                  return _OptionButton(
                    label: String.fromCharCode(65 + i),
                    text: q.options[i],
                    isSelected: state.selectedIndex == i,
                    isCorrect: state.isAnswered && i == q.correctIndex,
                    isWrong:
                        state.isAnswered &&
                        state.selectedIndex == i &&
                        i != q.correctIndex,
                    isAnswered: state.isAnswered,
                    onTap: state.isAnswered
                        ? null
                        : () => bloc.add(GrammarOptionSelected(i)),
                  );
                }),
                if (state.isAnswered) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: state.isCorrect ? Teal50 : Coral50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isCorrect ? 'Correct! 🎉' : 'Not quite 💡',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: state.isCorrect ? Teal600 : Coral600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          q.explanation,
                          style: TextStyle(
                            fontSize: 13,
                            color: state.isCorrect ? Teal600 : Coral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Purple600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => bloc.add(const GrammarNextQuestion()),
                      child: const Text(
                        'Next question →',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
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

class _SentenceWithBlank extends StatelessWidget {
  final String sentence;
  final String blankWord;
  final bool isAnswered;

  const _SentenceWithBlank({
    required this.sentence,
    required this.blankWord,
    required this.isAnswered,
  });

  @override
  Widget build(BuildContext context) {
    final parts = sentence.split('___');
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.7,
        ),
        children: [
          TextSpan(text: parts.first),
          WidgetSpan(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isAnswered ? Teal600 : Purple600,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                isAnswered ? blankWord : '  ?  ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isAnswered ? Teal600 : Purple600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts.last),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool isAnswered;
  final VoidCallback? onTap;

  const _OptionButton({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.isAnswered,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color borderColor = Colors.black.withOpacity(0.12);
    Color textColor = Colors.black87;

    if (isCorrect) {
      bg = Teal50;
      borderColor = Teal600;
      textColor = Teal600;
    } else if (isWrong) {
      bg = Coral50;
      borderColor = Coral600;
      textColor = Coral600;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: borderColor, width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              '$label — ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 14, color: textColor),
              ),
            ),
            if (isCorrect) Icon(Icons.check, color: Teal600, size: 18),
            if (isWrong) Icon(Icons.close, color: Coral600, size: 18),
          ],
        ),
      ),
    );
  }
}

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
