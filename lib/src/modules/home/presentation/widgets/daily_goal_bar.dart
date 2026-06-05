// ── Daily goal bar ─────────────────────

import 'package:flutter/material.dart';
import 'package:images/src/modules/home/domain/user_stats_model.dart';
import 'package:images/src/utils/color.dart';

class DailyGoalBar extends StatelessWidget {
  final UserStats stats;
  const DailyGoalBar({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final pct = (stats.dailyProgress * 100).round();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: CustomColors.Blue200, width: 0.5),
        color: CustomColors.Blue50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily goal · $pct% done',
                style: const TextStyle(
                  color: CustomColors.Blue600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${stats.completedMinutes} / ${stats.dailyGoalMinutes} min',
                style: const TextStyle(
                  color: CustomColors.Blue600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: stats.dailyProgress,
              minHeight: 6,
              backgroundColor: CustomColors.Blue200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                CustomColors.Blue600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
