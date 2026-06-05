// ── Hero header ────────────────────────

import 'package:flutter/material.dart';
import 'package:images/src/modules/home/domain/user_stats_model.dart';
import 'package:images/src/modules/home/presentation/widgets/stats_row.dart';
import 'package:images/src/utils/color.dart';

class HeroHeader extends StatelessWidget {
  final UserStats stats;
  const HeroHeader({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 36,
      ),
      decoration: const BoxDecoration(color: CustomColors.Purple800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning 👋',
                      style: const TextStyle(
                        color: CustomColors.Purple200,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stats.name,
                      style: const TextStyle(
                        color: CustomColors.Purple50,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _AvatarBadge(),
            ],
          ),
          const SizedBox(height: 20),
          StatsRow(stats: stats),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: CustomColors.Purple600,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            color: CustomColors.Purple50,
            size: 20,
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: CustomColors.Teal200,
              shape: BoxShape.circle,
              border: Border.all(color: CustomColors.Purple800, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
