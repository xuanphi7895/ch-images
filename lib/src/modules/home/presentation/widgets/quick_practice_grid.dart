// ── Quick practice grid ─────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/home/domain/quick_practice_model.dart';
import 'package:images/src/modules/home/presentation/bloc/home_bloc.dart';
import 'package:images/src/modules/home/presentation/bloc/home_event.dart';
import 'package:images/src/utils/color.dart';
import 'package:images/src/utils/enum.dart';

class QuickPracticeGrid extends StatelessWidget {
  final List<QuickPractice> items;
  const QuickPracticeGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.4,
        ),
        itemCount: items.length,
        itemBuilder: (ctx, i) => _PracticeCard(item: items[i]),
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  final QuickPractice item;
  const _PracticeCard({required this.item});

  IconData get _icon {
    switch (item.skill) {
      case SkillType.vocabulary:
        return Icons.spellcheck_outlined;
      case SkillType.grammar:
        return Icons.edit_note_outlined;
      case SkillType.reading:
        return Icons.menu_book_outlined;
      case SkillType.pronunciation:
        return Icons.mic_none_outlined;
    }
  }

  Color get _color {
    switch (item.skill) {
      case SkillType.vocabulary:
        return CustomColors.Purple600;
      case SkillType.grammar:
        return CustomColors.Teal600;
      case SkillType.reading:
        return CustomColors.Coral600;
      case SkillType.pronunciation:
        return CustomColors.Blue600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.read<HomeBloc>().add(QuickPracticeTapped(item.skill)),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, color: _color, size: 24),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
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
