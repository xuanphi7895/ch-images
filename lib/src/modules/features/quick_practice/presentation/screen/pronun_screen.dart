import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/pronun_bloc.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/pronun_event.dart';
import 'package:images/src/modules/features/quick_practice/presentation/bloc/pronun_state.dart';
import 'package:images/src/modules/features/quick_practice/presentation/screen/result_screen.dart';
import 'package:images/src/modules/features/quick_practice/presentation/widgets/practice_header.dart';
import 'package:images/src/utils/enum.dart';
import 'package:images/src/modules/features/quick_practice/domain/session_result.dart';

// ════════════════════════════════════════════════════
// PRONUNCIATION SCREEN
// ════════════════════════════════════════════════════

class PronunScreen extends StatelessWidget {
  const PronunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PronunBloc()..add(const PronunStarted()),
      child: const _PronunView(),
    );
  }
}

class _PronunView extends StatelessWidget {
  const _PronunView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<PronunBloc, PronunState>(
        listener: (context, state) {
          if (state is PronunSessionDone) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ResultScreen(
                  result: SessionResult(
                    skill: SkillType.pronunciation,
                    xpEarned: state.xpEarned,
                    accuracyPercent: state.accuracyPercent,
                    durationSeconds: state.durationSeconds,
                    easyCount: 0,
                    hardCount: 0,
                    againCount: 0,
                  ),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PronunLoading || state is PronunInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Purple600),
            );
          }
          if (state is PronunWordVisible) {
            return _PronunWordPage(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PronunWordPage extends StatelessWidget {
  final PronunWordVisible state;
  const _PronunWordPage({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PronunBloc>();
    final word = state.word;
    final isRecording = state.status == RecordingStatus.recording;
    final isAnalyzing = state.status == RecordingStatus.analyzing;
    final isResult = state.status == RecordingStatus.result;

    return Column(
      children: [
        PracticeHeader(
          title:
              'Pronunciation · ${state.currentIndex + 1} / ${state.totalWords}',
          progress: state.progress,
          trailing: '',
          onClose: () => Navigator.pop(context),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  word.ipa,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.45),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CircleActionButton(
                      icon: Icons.volume_up_outlined,
                      color: Purple600,
                      label: 'Listen',
                      isActive: state.status == RecordingStatus.playing,
                      onTap: () => bloc.add(const PronunPlaybackRequested()),
                    ),
                    const SizedBox(width: 20),
                    _CircleActionButton(
                      icon: isRecording ? Icons.stop : Icons.mic_none_outlined,
                      color: Coral600,
                      label: isRecording ? 'Stop' : 'Record',
                      isActive: isRecording,
                      onTap: isAnalyzing
                          ? null
                          : () {
                              if (isRecording) {
                                bloc.add(const PronunRecordingSubmitted());
                              } else {
                                bloc.add(const PronunRecordingStarted());
                              }
                            },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (isAnalyzing)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: Purple600),
                        SizedBox(height: 12),
                        Text(
                          'Analyzing your pronunciation…',
                          style: TextStyle(fontSize: 13, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                if (isResult && state.result != null) ...[
                  _WaveformComparison(),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: state.result!.scorePercent >= 70
                          ? Teal50
                          : Coral50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Score: ${state.result!.scorePercent}% match',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: state.result!.scorePercent >= 70
                                ? Teal600
                                : Coral600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.result!.tip,
                          style: TextStyle(
                            fontSize: 13,
                            color: state.result!.scorePercent >= 70
                                ? Teal600
                                : Coral600,
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
                      onPressed: () => bloc.add(const PronunNextWord()),
                      child: const Text(
                        'Next word →',
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

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _CircleActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? color.withOpacity(0.12) : Colors.white,
              border: Border.all(color: color, width: isActive ? 2.5 : 1.5),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.black45)),
        ],
      ),
    );
  }
}

class _WaveformComparison extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waveform comparison',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 10),
          _WaveformRow(
            label: 'Native',
            color: Purple600,
            heights: [8, 14, 18, 12, 18, 14, 10, 16, 8],
          ),
          const SizedBox(height: 8),
          _WaveformRow(
            label: 'You',
            color: Teal600,
            heights: [6, 12, 16, 10, 16, 14, 8, 14, 6],
          ),
        ],
      ),
    );
  }
}

class _WaveformRow extends StatelessWidget {
  final String label;
  final Color color;
  final List<int> heights;

  const _WaveformRow({
    required this.label,
    required this.color,
    required this.heights,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 46,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.45),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: heights
                  .map(
                    (h) => Container(
                      width: 4,
                      height: h.toDouble(),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
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
