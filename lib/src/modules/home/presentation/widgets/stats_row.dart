// ── Stats row ──────────────────────────

import 'package:flutter/material.dart';
import 'package:images/src/modules/home/domain/user_stats_model.dart';
import 'package:images/src/utils/color.dart';

class StatsRow extends StatelessWidget {
  final UserStats stats;
  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          label: 'day streak',
          value: '🔥 ${stats.streakDays}',
          valueColor: CustomColors.Amber400,
        ),
        const SizedBox(width: 10),
        _StatChip(
          label: 'this week',
          value: '${stats.weeklyXp} XP',
          valueColor: CustomColors.Teal200,
        ),
        const SizedBox(width: 10),
        _StatChip(
          label: 'level',
          value: stats.level,
          valueColor: const Color(0xFFED93B1),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: CustomColors.Purple200,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
