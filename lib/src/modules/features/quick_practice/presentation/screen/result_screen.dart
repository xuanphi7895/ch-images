// result_screen.dart
import 'package:flutter/material.dart';
import 'package:images/src/modules/features/quick_practice/domain/session_result.dart';
import 'package:images/src/utils/enum.dart';

const Purple800 = Color(0xFF3C3489);
const Purple600 = Color(0xFF534AB7);
const Teal600 = Color(0xFF0F6E56);
const Blue600 = Color(0xFF185FA5);
const Coral600 = Color(0xFF993C1D);

class ResultScreen extends StatelessWidget {
  final SessionResult result;
  const ResultScreen({super.key, required this.result});

  String get _skillLabel {
    switch (result.skill) {
      case SkillType.vocabulary:
        return 'Vocabulary';
      case SkillType.grammar:
        return 'Grammar';
      case SkillType.pronunciation:
        return 'Pronunciation';
      case SkillType.reading:
        return 'Reading';
      case SkillType.speaking:
        return 'Speaking';
    }
  }

  String get _durationLabel {
    final m = result.durationSeconds ~/ 60;
    final s = result.durationSeconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 28,
              bottom: 40,
              left: 16,
              right: 16,
            ),
            color: Purple800,
            width: double.infinity,
            child: Column(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 10),
                const Text(
                  'Session complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFEEEDFE),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _skillLabel,
                  style: const TextStyle(
                    color: Color(0xFFAFA9EC),
                    fontSize: 14,
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
                  // Stats row
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.08),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _StatCard(
                              label: 'XP earned',
                              value: '+${result.xpEarned}',
                              valueColor: Colors.black87,
                            ),
                            const SizedBox(width: 10),
                            _StatCard(
                              label: 'Accuracy',
                              value: '${result.accuracyPercent}%',
                              valueColor: Teal600,
                            ),
                            const SizedBox(width: 10),
                            _StatCard(
                              label: 'Time',
                              value: _durationLabel,
                              valueColor: Colors.black87,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (result.skill == SkillType.vocabulary) ...[
                          Text(
                            'Skill breakdown',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withOpacity(0.45),
                              letterSpacing: .05,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _BreakdownBar(
                            label: 'Easy (knew well)',
                            count: result.easyCount,
                            total: result.totalCards,
                            color: Teal600,
                          ),
                          const SizedBox(height: 8),
                          _BreakdownBar(
                            label: 'Hard (needs review)',
                            count: result.hardCount,
                            total: result.totalCards,
                            color: Blue600,
                          ),
                          const SizedBox(height: 8),
                          _BreakdownBar(
                            label: 'Again (forgotten)',
                            count: result.againCount,
                            total: result.totalCards,
                            color: Coral600,
                          ),
                        ] else ...[
                          Text(
                            'Skill breakdown',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withOpacity(0.45),
                              letterSpacing: .05,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _BreakdownBar(
                            label: 'Correct',
                            count: result.easyCount,
                            total: result.easyCount + result.againCount,
                            color: Teal600,
                          ),
                          const SizedBox(height: 8),
                          _BreakdownBar(
                            label: 'Incorrect',
                            count: result.againCount,
                            total: result.easyCount + result.againCount,
                            color: Coral600,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // CTAs
                  if (result.skill == SkillType.vocabulary &&
                      (result.hardCount + result.againCount) > 0)
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
                        onPressed: () {
                          // TODO: re-queue hard + again cards
                        },
                        child: const Text(
                          'Review hard & forgotten cards',
                          style: TextStyle(color: Colors.white, fontSize: 14),
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
                          Navigator.popUntil(context, (route) => route.isFirst),
                      child: const Text(
                        'Back to home',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _BreakdownBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: Colors.black.withOpacity(0.07),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
